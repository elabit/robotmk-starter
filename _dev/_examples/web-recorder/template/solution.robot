*** Settings ***
Documentation   This is an exmaple of keywords that have been recorded using the Keyword Recorder 
...   of the Browser Library (new in 21.0.0). 
# Load common keywords from a shared file
Resource  Resources/BrowserCommon.resource 


Suite Setup     BrowserCommon.Browser Init
Test Setup      Test Initialization

*** Variables ***

# Get your own free demo account at https://demo.robotmk.org
# ${URL}   https://demo.robotmk.org/w/h8wg-y545-uaq5-etvb-qmkg/

*** Test Cases ***
Test One
    Order Burger  without onions

*** Keywords ***

Test Initialization
    New Context    locale=en-GB
    New Page       url=${URL}
    Reset Park

Reset Park
    [Tags]    recorded
    Click    [data-test="reset"]
    Click    [data-test="reset-confirm"]
    Get Text    [data-test="message"]    contains    The park is back to opening time.

Order Burger
    [Tags]    recorded
    [Arguments]    ${special_request}
    Click    [data-test="nav-till"]
    Click    [data-test="item-burger-cheese"]
    Click    [data-test="note-burger-cheese"]
    Fill Text    [data-test="note-burger-cheese"]    ${special_request}
    Click    [data-test="place-order"]
    Get Text    [data-test="order-total"]    contains    7,90 €
    Click    [data-test="receipt-close"]
