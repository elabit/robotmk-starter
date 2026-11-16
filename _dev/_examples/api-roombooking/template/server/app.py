"""Meeting room booking API — a small, self-contained demo server for REST API tests.

Start it manually to explore the API in the browser:

    python server/app.py            # then open http://127.0.0.1:8765/docs

All data lives in memory and is reset on every start.
"""

import argparse
import secrets
from datetime import date, datetime, time
from itertools import count

import uvicorn
from fastapi import FastAPI, Header, HTTPException, Query, Response, status
from pydantic import BaseModel, Field, field_validator

app = FastAPI(
    title="Meeting Room Booking API",
    description="Find a free meeting room, book it, reschedule or cancel the booking.",
    version="1.0.0",
)

OPENING, CLOSING = time(8, 0), time(18, 0)

USERS = {"alice": "wonderland", "bob": "builder"}  # username -> password
TOKENS: dict[str, str] = {}  # token -> username

ROOMS = {
    "lovelace": {"id": "lovelace", "name": "Lovelace", "capacity": 2, "equipment": []},
    "ada": {"id": "ada", "name": "Ada", "capacity": 4, "equipment": ["screen"]},
    "turing": {"id": "turing", "name": "Turing", "capacity": 8, "equipment": ["beamer", "whiteboard", "video"]},
    "hopper": {"id": "hopper", "name": "Hopper", "capacity": 12, "equipment": ["beamer", "video"]},
}

BOOKINGS: dict[int, dict] = {}
_next_id = count(1)


# ── Models ───────────────────────────────────────────────────────────────────


def _naive(value: datetime | None) -> datetime | None:
    """Store everything as naive local time; convert timezone-aware input."""
    if value is not None and value.tzinfo is not None:
        return value.astimezone().replace(tzinfo=None)
    return value


class Credentials(BaseModel):
    username: str
    password: str


class BookingIn(BaseModel):
    room_id: str
    title: str = Field(min_length=1, max_length=100)
    start: datetime
    end: datetime
    attendees: int = Field(default=1, ge=1)

    _tz = field_validator("start", "end")(_naive)


class BookingPatch(BaseModel):
    """All fields optional: only the given fields are changed."""

    room_id: str | None = None
    title: str | None = Field(default=None, min_length=1, max_length=100)
    start: datetime | None = None
    end: datetime | None = None
    attendees: int | None = Field(default=None, ge=1)

    _tz = field_validator("start", "end")(_naive)


# ── Helpers ──────────────────────────────────────────────────────────────────


def current_user(authorization: str | None) -> str:
    scheme, _, token = (authorization or "").partition(" ")
    if scheme.lower() != "bearer" or token not in TOKENS:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Missing or invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return TOKENS[token]


def get_room(room_id: str) -> dict:
    if room_id not in ROOMS:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"Room '{room_id}' not found")
    return ROOMS[room_id]


def own_booking(booking_id: int, user: str) -> dict:
    booking = BOOKINGS.get(booking_id)
    if booking is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"Booking {booking_id} not found")
    if booking["owner"] != user:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "This booking belongs to someone else")
    return booking


def validate(data: dict, ignore_id: int | None = None) -> None:
    """Business rules every new or changed booking must follow."""

    def reject(msg: str, code: int = status.HTTP_422_UNPROCESSABLE_CONTENT):
        raise HTTPException(code, msg)

    room = ROOMS.get(data["room_id"])
    if room is None:
        reject(f"Room '{data['room_id']}' does not exist")
    start, end = data["start"], data["end"]
    if end <= start:
        reject("A booking must end after it starts")
    if start < datetime.now():
        reject("Bookings in the past are not possible")
    if start.date() != end.date() or start.time() < OPENING or end.time() > CLOSING:
        reject(f"Rooms can only be booked between {OPENING:%H:%M} and {CLOSING:%H:%M} on the same day")
    if data["attendees"] > room["capacity"]:
        reject(f"Room '{room['id']}' holds max. {room['capacity']} people")
    for other in BOOKINGS.values():
        if other["id"] != ignore_id and other["room_id"] == room["id"]:
            if start < other["end"] and other["start"] < end:
                reject(
                    f"Room '{room['id']}' is already booked from "
                    f"{other['start']:%H:%M} to {other['end']:%H:%M}",
                    status.HTTP_409_CONFLICT,
                )


# ── Endpoints ────────────────────────────────────────────────────────────────


@app.get("/health", tags=["monitoring"])
def health():
    return {"status": "ok", "rooms": len(ROOMS), "bookings": len(BOOKINGS)}


@app.post("/auth/token", tags=["auth"])
def login(credentials: Credentials):
    if USERS.get(credentials.username) != credentials.password:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Wrong username or password")
    token = secrets.token_urlsafe(16)
    TOKENS[token] = credentials.username
    return {"access_token": token, "token_type": "bearer"}


@app.get("/rooms", tags=["rooms"])
def list_rooms(min_capacity: int = 1, equipment: list[str] = Query(default=[])):
    """Filter rooms, e.g. `/rooms?min_capacity=6&equipment=beamer`."""
    return [
        room
        for room in ROOMS.values()
        if room["capacity"] >= min_capacity and set(equipment) <= set(room["equipment"])
    ]


@app.api_route("/rooms/{room_id}", methods=["GET", "HEAD"], tags=["rooms"])
def room_details(room_id: str):
    """HEAD returns the same status code as GET, but no body — a cheap existence check."""
    return get_room(room_id)


@app.get("/rooms/{room_id}/availability", tags=["rooms"])
def availability(room_id: str, day: date = Query(alias="date")):
    """Booked and free time slots of a room on one day."""
    get_room(room_id)
    booked = sorted(
        (b for b in BOOKINGS.values() if b["room_id"] == room_id and b["start"].date() == day),
        key=lambda b: b["start"],
    )
    free, cursor = [], datetime.combine(day, OPENING)
    for b in booked:
        if b["start"] > cursor:
            free.append({"start": cursor, "end": b["start"]})
        cursor = max(cursor, b["end"])
    if cursor < datetime.combine(day, CLOSING):
        free.append({"start": cursor, "end": datetime.combine(day, CLOSING)})
    return {
        "room_id": room_id,
        "date": day,
        "booked": [{"start": b["start"], "end": b["end"]} for b in booked],
        "free": free,
    }


@app.get("/bookings", tags=["bookings"])
def my_bookings(
    room_id: str | None = None,
    day: date | None = Query(default=None, alias="date"),
    authorization: str | None = Header(default=None),
):
    user = current_user(authorization)
    return [
        b
        for b in BOOKINGS.values()
        if b["owner"] == user
        and (room_id is None or b["room_id"] == room_id)
        and (day is None or b["start"].date() == day)
    ]


@app.post("/bookings", status_code=status.HTTP_201_CREATED, tags=["bookings"])
def create_booking(booking: BookingIn, response: Response, authorization: str | None = Header(default=None)):
    user = current_user(authorization)
    data = booking.model_dump()
    validate(data)
    data.update(id=next(_next_id), owner=user)
    BOOKINGS[data["id"]] = data
    response.headers["Location"] = f"/bookings/{data['id']}"
    return data


@app.options("/bookings/{booking_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["bookings"])
def booking_options(booking_id: int, response: Response):
    """Which methods does a booking support? The answer is in the Allow header."""
    response.headers["Allow"] = "GET, PUT, PATCH, DELETE, OPTIONS"


@app.get("/bookings/{booking_id}", tags=["bookings"])
def read_booking(booking_id: int, authorization: str | None = Header(default=None)):
    return own_booking(booking_id, current_user(authorization))


@app.put("/bookings/{booking_id}", tags=["bookings"])
def replace_booking(booking_id: int, booking: BookingIn, authorization: str | None = Header(default=None)):
    """Replace the whole booking. Fields left out fall back to their defaults."""
    existing = own_booking(booking_id, current_user(authorization))
    data = booking.model_dump()
    validate(data, ignore_id=booking_id)
    existing.update(data)
    return existing


@app.patch("/bookings/{booking_id}", tags=["bookings"])
def update_booking(booking_id: int, changes: BookingPatch, authorization: str | None = Header(default=None)):
    """Change only the given fields, e.g. move the meeting or rename it."""
    existing = own_booking(booking_id, current_user(authorization))
    data = {**existing, **changes.model_dump(exclude_unset=True, exclude_none=True)}
    validate(data, ignore_id=booking_id)
    existing.update(data)
    return existing


@app.delete("/bookings/{booking_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["bookings"])
def cancel_booking(booking_id: int, authorization: str | None = Header(default=None)):
    own_booking(booking_id, current_user(authorization))
    del BOOKINGS[booking_id]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    uvicorn.run(app, host=args.host, port=args.port, log_level="warning")
