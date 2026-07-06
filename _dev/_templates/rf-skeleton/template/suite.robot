*** Settings ***
Documentation       A minimal Robot Framework skeleton

# Resource   Resources/CommonKeywords.resource
# Resource   Data/MyVariables.resource

#Suite Setup     Suite Initialization
#Suite Teardown  Suite Finalization

#Test Setup      Test Initialization
#Test Teardown   Test Finalization

*** Variables ***
${FOO}  bar

*** Test Cases ***

Test One
    [Documentation]    First test case
    Log   Test is fine!

# Suite Initialization
#     Log    Write common preparation steps here

# Suite Finalization
#     Log    Write common cleanup steps here

# Test Initialization
#     Log    Write test-specific preparation steps here

# Test Finalization
#     Log    Write test-specific cleanup steps here
