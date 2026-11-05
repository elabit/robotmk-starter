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
    Record Keywords

*** Keywords ***

Test Initialization
    New Context    locale=en-GB
    New Page       url=${URL}
