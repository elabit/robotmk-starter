*** Settings ***
Documentation       Business layer: what a user does with the meeting room booking API.
...                 Each keyword names the HTTP request it sends. All bookings are for tomorrow;
...                 times are given as HH:MM. Requests are sent as the user of the last `Log In As`.

Resource            BookingApi.resource
Library             Collections
Library             DateTime


*** Keywords ***
# ── Setup & cleanup ──────────────────────────────────────────────────────────

Start Booking API
    [Documentation]    Starts the server and logs in all test users.
    Start Booking API Server
    FOR    ${user}    IN    @{PASSWORDS}
        Open User Session    ${user}
    END
    ${tomorrow}=    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    VAR    ${TOMORROW}    ${tomorrow}    scope=SUITE

Stop Booking API
    Stop Booking API Server

Cancel All Bookings
    [Documentation]    Cleanup after each test: every user's bookings are deleted (GET + DELETE).
    FOR    ${user}    IN    @{PASSWORDS}
        ${resp}=    GET On Session    ${user}    /bookings
        FOR    ${booking}    IN    @{resp.json()}
            DELETE On Session    ${user}    /bookings/${booking}[id]
        END
    END

# ── Users ────────────────────────────────────────────────────────────────────

Log In As
    [Documentation]    All following requests are sent as this user.
    [Arguments]    ${user}
    VAR    ${CURRENT_USER}    ${user}    scope=TEST

Login Should Fail
    [Documentation]    POST /auth/token with a wrong password → 401.
    [Arguments]    ${user}    ${password}
    &{credentials}=    Create Dictionary    username=${user}    password=${password}
    POST On Session    anonymous    /auth/token    json=${credentials}    expected_status=401

Bookings Should Not Be Visible Without Login
    [Documentation]    GET /bookings without a token → 401.
    GET On Session    anonymous    /bookings    expected_status=401

# ── Health ───────────────────────────────────────────────────────────────────

Booking API Should Be Up And Fast
    [Documentation]    GET /health
    ${resp}=    GET On Session    anonymous    /health
    Should Be Equal    ${resp.json()}[status]    ok
    Response Should Be Fast    ${resp}

# ── Rooms ────────────────────────────────────────────────────────────────────

Search Rooms
    [Documentation]    GET /rooms with query parameters; returns the matching rooms.
    [Arguments]    ${for}    ${with}
    &{filter}=    Create Dictionary    min_capacity=${for}    equipment=${with}
    ${resp}=    GET On Session    anonymous    /rooms    params=${filter}
    Should Not Be Empty    ${resp.json()}    msg=No room for ${for} people with ${with}
    RETURN    ${resp.json()}

Every Room Should Fit
    [Arguments]    ${rooms}    ${people}    ${equipment}
    FOR    ${room}    IN    @{rooms}
        Should Be True    ${room}[capacity] >= ${people}
        Should Contain    ${room}[equipment]    ${equipment}
    END

Room Should Exist
    [Documentation]    HEAD /rooms/{room}: same status code as GET, but no body.
    [Arguments]    ${room}
    ${resp}=    HEAD On Session    anonymous    /rooms/${room}
    Should Be Empty    ${resp.text}

Room Should Not Exist
    [Documentation]    HEAD /rooms/{room} → 404
    [Arguments]    ${room}
    HEAD On Session    anonymous    /rooms/${room}    expected_status=404

Room Should Be Booked
    [Documentation]    GET /rooms/{room}/availability: the slot is in the room's calendar.
    [Arguments]    ${room}    ${from}    ${to}
    ${resp}=    GET On Session    anonymous    /rooms/${room}/availability    params=date=${TOMORROW}
    &{slot}=    Create Dictionary    start=${TOMORROW}T${from}:00    end=${TOMORROW}T${to}:00
    Should Contain    ${resp.json()}[booked]    ${slot}

# ── Bookings ─────────────────────────────────────────────────────────────────

Book Room
    [Documentation]    POST /bookings → 201. Returns the URL of the new booking (Location header).
    [Arguments]    ${room}    ${from}    ${to}    ${title}=Team meeting    ${attendees: int}=2
    ${resp}=    Send Booking    ${room}    ${from}    ${to}    ${title}    ${attendees}    expected_status=201
    RETURN    ${resp.headers}[Location]

Booking Should Be Rejected
    [Documentation]    POST /bookings is refused: 422 (invalid) or 409 (conflict), with the reason.
    [Arguments]    ${room}    ${from}    ${to}    ${attendees: int}=2    ${reason}=${EMPTY}    ${status}=422
    ${resp}=    Send Booking    ${room}    ${from}    ${to}    Team meeting    ${attendees}    expected_status=${status}
    Should Contain    ${resp.json()}[detail]    ${reason}

Booking Should Have
    [Documentation]    GET /bookings/{id}: the booking has the given field values, e.g. title=Weekly.
    [Arguments]    ${booking}    &{expected}
    ${resp}=    GET On Session    ${CURRENT_USER}    ${booking}
    Response Should Be Fast    ${resp}
    Dictionary Should Contain Sub Dictionary    ${resp.json()}    ${expected}

Booking Should Allow
    [Documentation]    OPTIONS /bookings/{id}: the Allow header lists the given methods.
    [Arguments]    ${booking}    @{methods}
    ${resp}=    OPTIONS On Session    ${CURRENT_USER}    ${booking}
    FOR    ${method}    IN    @{methods}
        Should Contain    ${resp.headers}[Allow]    ${method}
    END

Move Booking
    [Documentation]    PATCH /bookings/{id}: changes only the time, everything else stays.
    [Arguments]    ${booking}    ${from}    ${to}
    &{changes}=    Create Dictionary    start=${TOMORROW}T${from}:00    end=${TOMORROW}T${to}:00
    PATCH On Session    ${CURRENT_USER}    ${booking}    json=${changes}

Replace Booking
    [Documentation]    PUT /bookings/{id}: replaces the whole booking.
    [Arguments]    ${booking}    ${room}    ${from}    ${to}    ${title}    ${attendees: int}
    ${body}=    Booking Data    ${room}    ${from}    ${to}    ${title}    ${attendees}
    PUT On Session    ${CURRENT_USER}    ${booking}    json=${body}

Cancel Booking
    [Documentation]    DELETE /bookings/{id} → 204
    [Arguments]    ${booking}
    DELETE On Session    ${CURRENT_USER}    ${booking}    expected_status=204

Cancelling Should Be Forbidden
    [Documentation]    DELETE /bookings/{id} of somebody else → 403
    [Arguments]    ${booking}
    DELETE On Session    ${CURRENT_USER}    ${booking}    expected_status=403

Booking Should Exist
    [Documentation]    GET /bookings/{id} → 200
    [Arguments]    ${booking}
    GET On Session    ${CURRENT_USER}    ${booking}    expected_status=200

Booking Should Not Exist
    [Documentation]    GET /bookings/{id} → 404
    [Arguments]    ${booking}
    GET On Session    ${CURRENT_USER}    ${booking}    expected_status=404

# ── Helpers ──────────────────────────────────────────────────────────────────

Send Booking
    [Arguments]    ${room}    ${from}    ${to}    ${title}    ${attendees}    ${expected_status}
    ${body}=    Booking Data    ${room}    ${from}    ${to}    ${title}    ${attendees}
    ${resp}=    POST On Session    ${CURRENT_USER}    /bookings    json=${body}    expected_status=${expected_status}
    RETURN    ${resp}

Booking Data
    [Documentation]    The JSON body of a booking.
    [Arguments]    ${room}    ${from}    ${to}    ${title}    ${attendees: int}
    &{body}=    Create Dictionary    room_id=${room}    title=${title}
    ...    start=${TOMORROW}T${from}:00    end=${TOMORROW}T${to}:00    attendees=${attendees}
    RETURN    ${body}
