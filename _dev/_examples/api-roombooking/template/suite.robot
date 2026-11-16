*** Settings ***
Documentation       REST API testing with the **RequestsLibrary** on a meeting room booking API:
...                 find a room, book it, reschedule and cancel it. Covers GET, HEAD, OPTIONS, POST, PUT, PATCH
...                 and DELETE, token login and error cases. A local demo API server is started in the Suite Setup.

Resource            Resources/BookingApi.resource

Suite Setup         Start API And Log In
Suite Teardown      Stop Booking API Server
Test Teardown       Cancel Bookings Of All Users


*** Test Cases ***
API Is Up And Fast
    [Documentation]    The most basic monitoring check: the API answers, and it answers quickly.
    ${resp}=    GET On Session    anonymous    /health
    Should Be Equal    ${resp.json()}[status]    ok
    Response Should Be Fast    ${resp}

Find A Room For Six People With A Beamer
    [Documentation]    GET with query parameters; HEAD as a cheap "does it exist?" check.
    &{filter}=    Create Dictionary    min_capacity=6    equipment=beamer
    ${resp}=    GET On Session    anonymous    /rooms    params=${filter}
    Should Not Be Empty    ${resp.json()}
    FOR    ${room}    IN    @{resp.json()}
        Should Be True    ${room}[capacity] >= 6
        Should Contain    ${room}[equipment]    beamer
    END
    ${resp}=    HEAD On Session    anonymous    /rooms/turing
    Should Be Empty    ${resp.text}
    HEAD On Session    anonymous    /rooms/broom-closet    expected_status=404

Book, Reschedule And Cancel A Meeting
    [Documentation]    The whole life of a booking: POST, GET, OPTIONS, PATCH, PUT and DELETE.
    # POST creates the booking: 201 + the URL of the new booking in the Location header
    ${resp}=    Book Room    alice    turing    10:00    11:00
    ...    title=Sprint planning    attendees=6
    ${url}=    Set Variable    ${resp.headers}[Location]

    # GET reads it back
    ${resp}=    GET On Session    alice    ${url}
    Should Be Equal    ${resp.json()}[title]    Sprint planning
    Response Should Be Fast    ${resp}

    # OPTIONS asks which methods this resource supports (Allow header)
    ${resp}=    OPTIONS On Session    alice    ${url}
    Should Contain    ${resp.headers}[Allow]    PATCH

    # PATCH changes only the given fields: move the meeting one hour later
    &{changes}=    Create Dictionary    start=${TOMORROW}T11:00:00    end=${TOMORROW}T12:00:00
    ${resp}=    PATCH On Session    alice    ${url}    json=${changes}
    Should Be Equal    ${resp.json()}[start]    ${TOMORROW}T11:00:00
    Should Be Equal    ${resp.json()}[title]    Sprint planning

    # The room's calendar shows the new slot as taken
    ${resp}=    GET On Session    anonymous    /rooms/turing/availability    params=date=${TOMORROW}
    Should Contain    ${resp.json()}[booked]    ${{ {"start": $changes["start"], "end": $changes["end"]} }}

    # PUT replaces the whole booking: more people, so move to the biggest room
    &{booking}=    Create Dictionary    room_id=hopper    title=Sprint planning with stakeholders
    ...    start=${TOMORROW}T11:00:00    end=${TOMORROW}T12:00:00    attendees=${10}
    ${resp}=    PUT On Session    alice    ${url}    json=${booking}
    Should Be Equal    ${resp.json()}[room_id]    hopper

    # DELETE cancels it: 204, and afterwards the booking is gone
    DELETE On Session    alice    ${url}    expected_status=204
    GET On Session    alice    ${url}    expected_status=404

Double Booking Is Rejected
    [Documentation]    Two people want the same room at overlapping times: the second one gets 409 Conflict.
    Book Room    alice    ada    14:00    15:00
    ${resp}=    Book Room    bob    ada    14:30    15:30    expected_status=409
    Should Contain    ${resp.json()}[detail]    already booked

Invalid Bookings Are Rejected
    [Documentation]    Business rules: the API answers 422 and tells why.
    [Template]    Booking Should Be Rejected
    # room       from     to       attendees    reason
    ada          15:00    14:00    2            must end after it starts
    ada          19:00    20:00    2            between 08:00 and 18:00
    lovelace     09:00    10:00    5            holds max. 2 people
    attic        09:00    10:00    2            does not exist

Bookings Need A Valid Login
    [Documentation]    No token or a wrong password: 401 Unauthorized.
    GET On Session    anonymous    /bookings    expected_status=401
    &{credentials}=    Create Dictionary    username=alice    password=guessed
    POST On Session    anonymous    /auth/token    json=${credentials}    expected_status=401

Colleagues Cannot Cancel My Booking
    [Documentation]    Bob may not delete Alice's booking: 403 Forbidden, and the booking stays.
    ${resp}=    Book Room    alice    hopper    09:00    10:00
    ${url}=    Set Variable    ${resp.headers}[Location]
    DELETE On Session    bob    ${url}    expected_status=403
    GET On Session    alice    ${url}    expected_status=200


*** Keywords ***
Start API And Log In
    Start Booking API Server
    Log In As    alice    wonderland
    Log In As    bob    builder
    ${tomorrow}=    Get Date Of Tomorrow
    VAR    ${TOMORROW}    ${tomorrow}    scope=SUITE

Cancel Bookings Of All Users
    Cancel All Bookings Of    alice
    Cancel All Bookings Of    bob

Booking Should Be Rejected
    [Arguments]    ${room}    ${from}    ${to}    ${attendees}    ${reason}
    ${resp}=    Book Room    alice    ${room}    ${from}    ${to}
    ...    attendees=${attendees}    expected_status=422
    Should Contain    ${resp.json()}[detail]    ${reason}
