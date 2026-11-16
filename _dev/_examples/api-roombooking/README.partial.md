# api-roombooking

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

REST API testing with the [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests)
on a realistic use case: an office **meeting room booking API**. Employees log in, look for a free room,
book it, reschedule the meeting and cancel it — and the API has to enforce the rules:
no double bookings, only during business hours, not more people than chairs.

The API server comes with the example (`server/app.py`, FastAPI, in-memory data). The **Suite Setup starts it**
in the background with the Process library and waits until `/health` answers; the Suite Teardown stops it.
The server's log goes to `output/booking-api.log`.

What it demonstrates:

- all common request types: `GET` (with query parameters), `HEAD`, `OPTIONS`, `POST`, `PUT`, `PATCH`, `DELETE`
- token login: one RequestsLibrary session per user, sending its `Authorization: Bearer …` header
- checking status codes with `expected_status=` — including the error cases `401`, `403`, `404`, `409`, `422`
- reading JSON bodies and headers (`${resp.json()}[title]`, `${resp.headers}[Location]`)
- a response time limit (`Response Should Be Fast`) — what synthetic monitoring is about
- independent tests: every test cleans up its bookings in the Test Teardown

## The API

| Method | Endpoint | What it does |
|---|---|---|
| `GET` | `/health` | Is the API up? |
| `POST` | `/auth/token` | Log in (`alice`/`wonderland`, `bob`/`builder`), returns a bearer token |
| `GET` | `/rooms?min_capacity=6&equipment=beamer` | Find rooms |
| `GET` `HEAD` | `/rooms/{room_id}` | Room details / does the room exist? |
| `GET` | `/rooms/{room_id}/availability?date=YYYY-MM-DD` | Booked and free slots of a day |
| `GET` | `/bookings` | My bookings (filter: `room_id`, `date`) |
| `POST` | `/bookings` | Book a room → `201` + `Location` header, `409` if taken, `422` if invalid |
| `GET` | `/bookings/{id}` | Read a booking (`403` if it's not yours) |
| `OPTIONS` | `/bookings/{id}` | Which methods are allowed? (`Allow` header) |
| `PUT` | `/bookings/{id}` | Replace a booking |
| `PATCH` | `/bookings/{id}` | Change single fields, e.g. move the meeting |
| `DELETE` | `/bookings/{id}` | Cancel → `204` |

To explore the API in the browser, start the server and open the interactive docs at <http://127.0.0.1:8765/docs>:

```bash
python server/app.py
```

(Stop it before running the suite, which starts its own server on the same port.)

## Test Cases

| Test Case | Description |
| --- | --- |
| `API Is Up And Fast` | `GET /health` and check the response time |
| `Find A Room For Six People With A Beamer` | `GET` with query parameters; `HEAD` for an existing and a missing room |
| `Book, Reschedule And Cancel A Meeting` | The whole life of a booking: `POST` → `GET` → `OPTIONS` → `PATCH` → `PUT` → `DELETE` |
| `Double Booking Is Rejected` | Overlapping booking of the same room → `409 Conflict` |
| `Invalid Bookings Are Rejected` | Data-driven (`[Template]`): wrong times, too many people, unknown room → `422` |
| `Bookings Need A Valid Login` | No token, wrong password → `401` |
| `Colleagues Cannot Cancel My Booking` | Deleting somebody else's booking → `403` |

## Testing workflow

How to write a new API test, using this example as a pattern:

1. **Explore** the endpoint by hand first (`/docs` above, or `curl`): what does a good request look like, what does the API answer?
2. **Write one test per user journey**, not per endpoint: e.g. *book → read back → move → cancel*.
3. **Check every step**: the status code (`expected_status=`), the fields that matter and the response time.
   Add the error cases a real user would hit (wrong login, taken slot, invalid data).
4. **Clean up** what the test created (Test Teardown), so tests can run in any order and again and again.
5. **Run it locally** against the demo server (`robot .`), then **against the real API**:
   in real synthetic monitoring the API already runs somewhere, so skip the server start:

```bash
robot --variable START_SERVER:False --variable API_URL:https://booking.example.com .
```

6. **Schedule it in Robotmk**: the suite now tells you every few minutes whether people can still book a room — and how fast.

## Key Files

- `suite.robot` — the test cases (user journeys)
- `Resources/BookingApi.resource` — server start/stop, login, booking and check keywords
- `server/app.py` — the demo API server

## Links

### Recommended links for this example

- [RequestsLibrary keyword documentation](https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html)
- [Process library](https://robotframework.org/robotframework/latest/libraries/Process.html)
- [FastAPI](https://fastapi.tiangolo.com)

### General links & Documentation

- [Robot Framework](https://robotframework.org)
- [Robotmk Homepage](https://robotmk.org)
