*** Settings ***
Documentation       Keywords to talk to the meeting room booking API with the RequestsLibrary.

Library             RequestsLibrary
Library             Process
Library             DateTime
Library             OperatingSystem


*** Variables ***
# Set to False (robot --variable START_SERVER:False) to test an API that is already running
${START_SERVER}         ${True}
${API_PORT}             8765
${API_URL}              http://127.0.0.1:${API_PORT}
${SERVER_LOG}           ${EXECDIR}${/}output${/}booking-api.log
# Response time limit in seconds — the number synthetic monitoring cares about
${MAX_RESPONSE_TIME}    1.0


*** Keywords ***
Start Booking API Server
    [Documentation]    Starts the demo API server in the background (log: output/booking-api.log)
    ...    and waits until it answers.
    Create Session    anonymous    ${API_URL}    max_retries=0
    IF    ${START_SERVER}
        ${python}=    Evaluate    sys.executable    modules=sys
        Create Directory    ${{ os.path.dirname($SERVER_LOG) }}
        Start Process    ${python}    ${CURDIR}${/}..${/}server${/}app.py    --port    ${API_PORT}
        ...    alias=booking-api    stdout=${SERVER_LOG}    stderr=STDOUT
    END
    Wait Until Booking API Answers

Wait Until Booking API Answers
    [Documentation]    Polls /health for max. 20 seconds. If we started the server ourselves and it
    ...    has crashed (e.g. because the port is taken), fails at once with the server's output.
    WHILE    True    limit=20s    on_limit_message=Booking API at ${API_URL} did not answer within 20s
        IF    ${START_SERVER}    Booking API Server Should Be Running
        ${up}=    Run Keyword And Return Status    GET On Session    anonymous    /health
        IF    ${up}    BREAK
        Sleep    0.5s
    END

Booking API Server Should Be Running
    ${running}=    Is Process Running    booking-api
    IF    not ${running}
        ${output}=    Get File    ${SERVER_LOG}
        Fail    The booking API server has stopped:\n${output}
    END

Stop Booking API Server
    Terminate All Processes
    Delete All Sessions

Log In As
    [Documentation]    Gets a bearer token and opens a session named after the user,
    ...    which sends the token with every request.
    [Arguments]    ${user}    ${password}
    &{credentials}=    Create Dictionary    username=${user}    password=${password}
    ${resp}=    POST On Session    anonymous    /auth/token    json=${credentials}
    &{headers}=    Create Dictionary    Authorization=Bearer ${resp.json()}[access_token]
    Create Session    ${user}    ${API_URL}    headers=${headers}

Book Room
    [Documentation]    POSTs a booking for tomorrow (times as HH:MM) and checks the expected
    ...    status code (201 by default).
    [Arguments]    ${session}    ${room}    ${from}    ${to}
    ...    ${title}=Team meeting    ${attendees: int}=2    ${expected_status}=201
    &{booking}=    Create Dictionary    room_id=${room}    title=${title}
    ...    start=${TOMORROW}T${from}:00    end=${TOMORROW}T${to}:00    attendees=${attendees}
    ${resp}=    POST On Session    ${session}    /bookings    json=${booking}    expected_status=${expected_status}
    RETURN    ${resp}

Cancel All Bookings Of
    [Documentation]    Cleanup: deletes every booking of the user, so tests stay independent.
    [Arguments]    ${session}
    ${resp}=    GET On Session    ${session}    /bookings
    FOR    ${booking}    IN    @{resp.json()}
        DELETE On Session    ${session}    /bookings/${booking}[id]
    END

Response Should Be Fast
    [Arguments]    ${resp}
    ${seconds}=    Set Variable    ${resp.elapsed.total_seconds()}
    Should Be True    ${seconds} < ${MAX_RESPONSE_TIME}
    ...    msg=Response took ${seconds}s (limit: ${MAX_RESPONSE_TIME}s)

Get Date Of Tomorrow
    ${day}=    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    RETURN    ${day}
