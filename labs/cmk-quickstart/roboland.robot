*** Settings ***
Documentation       Roboland — your first synthetic check.
...
...                 One question, asked the way a guest would ask it:
...                 can somebody still buy a burger?
...
...                 Before you run this, set the environment variable
...                 ROBOLAND_KEY to your own workspace key. You get one at
...                 https://demo.robotmk.org — it is free and lasts 30 days.

Library             Browser
Library             BuiltIn

Suite Setup         Open the park
Suite Teardown      Close Browser


*** Variables ***
# Your key comes from the environment, never from this file. A key pasted in
# here gets committed by accident — and then it is in your repository forever.
${KEY}              %{ROBOLAND_KEY=NOT-SET}
${PARK}             https://demo.robotmk.org

# The browser opens for real, so you can watch it work. Set this to True once
# you are tired of watching — Checkmk will run it that way anyway.
${HEADLESS}         False

${ITEM}             burger-classic
${CASH}             20,00


*** Test Cases ***
A guest can buy a burger
    [Documentation]    Walks through the order counter and checks that the order
    ...                really got a number.
    ...
    ...                A counter that looks perfectly fine but quietly swallows
    ...                the order fails here. That is the whole point.
    Click                      css=[data-test="item-${ITEM}"]
    Fill Text                  css=[data-test="given"]           ${CASH}
    Click                      css=[data-test="place-order"]
    Wait For Elements State    css=[data-test="order-number"]    visible


*** Keywords ***
Open the park
    [Documentation]    Empties the workspace first, so every run starts from the
    ...                same shelf.
    ...
    ...                Without this the booth slowly runs out of buns, orders get
    ...                blocked, and the test turns red while the park is perfectly
    ...                healthy. Real applications rarely give you a reset button —
    ...                module 6 comes back to what you do then.
    Should Not Be Equal    ${KEY}    NOT-SET    values=False
    ...    msg=The environment variable ROBOLAND_KEY is not set. Get a free key at https://demo.robotmk.org and put it there, then start the test again.
    New Browser     chromium    headless=${HEADLESS}
    New Page        ${PARK}/w/${KEY}/reset
    Click           css=[data-test="reset-confirm"]
    Go To           ${PARK}/w/${KEY}/till
