*** Settings ***
Documentation       A minimal skeleton to start with BrowserLibrary and Resource files. 

Resource   Resources/lib-browser.resource
Resource   Resources/BrowserCommon.resource

Suite Setup     Browser Init
Test Setup      Session Init  ${URL}

*** Variables ***
${URL}              https://www.robotmk.org/en/blog/vscode-helsinki-shortcut/

*** Test Cases ***

Test One
    [Documentation]    First test case
    No Operation
