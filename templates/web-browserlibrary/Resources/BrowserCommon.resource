*** Settings ***
Resource   lib-Browser.resource


*** Keywords ***

Browser Init
    New Browser  headless=%{ROBOTMK_HEADLESS_HOST=false}  slowMo=1s

Session Init
    [Arguments]  ${url}
    New Context    locale=en-US
    New Page    ${url}

Take A Screenshot
    Take Screenshot  EMBED  fileType=jpeg  quality=80