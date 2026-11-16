*** Settings ***
Documentation       REST API testing with the **RequestsLibrary** on a meeting room booking API:
...                 find a room, book it, reschedule and cancel it. Covers GET, HEAD, OPTIONS, POST, PUT, PATCH
...                 and DELETE, token login and error cases. A local demo API server is started in the Suite Setup.

Resource            Resources/RoomBooking.resource

Suite Setup         Start Booking API
Suite Teardown      Stop Booking API
Test Teardown       Cancel All Bookings


*** Test Cases ***
API Is Up And Fast
    [Documentation]    The most basic monitoring check: the API answers, and it answers quickly.
    Booking API Should Be Up And Fast

Find A Room For Six People With A Beamer
    ${rooms}=    Search Rooms    for=6    with=beamer
    Every Room Should Fit    ${rooms}    people=6    equipment=beamer
    Room Should Exist    turing
    Room Should Not Exist    broom-closet

Book, Reschedule And Cancel A Meeting
    [Documentation]    The whole life of a booking.
    Log In As    alice
    ${meeting}=    Book Room    turing    10:00    11:00    title=Sprint planning    attendees=6
    Booking Should Have    ${meeting}    title=Sprint planning    room_id=turing
    Booking Should Allow    ${meeting}    PATCH    DELETE

    Move Booking    ${meeting}    11:00    12:00
    Room Should Be Booked    turing    11:00    12:00
    Booking Should Have    ${meeting}    title=Sprint planning

    Replace Booking    ${meeting}    hopper    11:00    12:00    Sprint planning with stakeholders    10
    Booking Should Have    ${meeting}    room_id=hopper

    Cancel Booking    ${meeting}
    Booking Should Not Exist    ${meeting}

Double Booking Is Rejected
    [Documentation]    Two people want the same room at overlapping times: the second one gets 409 Conflict.
    Log In As    alice
    Book Room    ada    14:00    15:00
    Log In As    bob
    Booking Should Be Rejected    ada    14:30    15:30    reason=already booked    status=409

Invalid Bookings Are Rejected
    [Documentation]    Business rules: the API answers 422 and tells why.
    [Setup]    Log In As    alice
    [Template]    Booking Should Be Rejected
    # room       from     to       attendees    reason
    ada          15:00    14:00    2            must end after it starts
    ada          19:00    20:00    2            between 08:00 and 18:00
    lovelace     09:00    10:00    5            holds max. 2 people
    attic        09:00    10:00    2            does not exist

Bookings Need A Valid Login
    Bookings Should Not Be Visible Without Login
    Login Should Fail    alice    guessed

Colleagues Cannot Cancel My Booking
    Log In As    alice
    ${meeting}=    Book Room    hopper    09:00    10:00
    Log In As    bob
    Cancelling Should Be Forbidden    ${meeting}
    Log In As    alice
    Booking Should Exist    ${meeting}
