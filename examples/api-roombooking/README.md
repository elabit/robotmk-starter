<!-- First include the example/template's partial. Examples include the exmaple-intro.partial in turn. -->

# api-roombooking

<!-- Common intro injected after H1 in every example README.
     Edit this file in _dev/_shared/ — do not edit the generated copy. -->

This repository provides a **working example** to learn and test [Robot Framework](https://robotframework.org/) automation - the test scripting language used by [Robotmk](https://www.robotmk.org) for *Synthetic Monitoring* in [Checkmk](https://checkmk.com).

## How to Run the example

### Run online in a VS Code Devcontainer (recommended)

This is the easiest way to run the example — no local installation needed. Just click the button below:

[![Run this Robot in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/example-api-roombooking)

→ [How to run the example in Codespace](https://github.com/elabit/robotmk-starter/blob/main/docs/example-guide.md)

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based development environment (VS Code) hosted by GitHub — no local installation needed.  

### Manually with RCC

To run Robot Framework suites manually, refer to the Robotmk blog post with the step-by-step instructions for RCC:
   
→ [How to Run Robot Framework Examples with RCC](https://www.robotmk.org/en/blog/rcc-efficient-python-integration/)  
→ [Troubleshooting RCC](https://www.robotmk.org/en/blog/rcctrouble/)


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



## Libraries and Versions used in this example

| Library | Version |
|---|---|
| Python | `3.12` |
| Robot Framework | `7.5` |
| robotframework-requests | `0.9.7` |
| fastapi (demo server) | `0.163.1` |
| uvicorn (demo server) | `0.54.0` |


## About

Also try the other [RF example suites](https://github.com/elabit/robotmk-starter#content), they all work in the Codespace environment.  

🪲 Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
