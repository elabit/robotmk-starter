*** Settings ***
Documentation   An example suite which demonstrates the usage of the new Keyword Recorder feature of the Robot Framework Browser Library (21.0.0)
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
