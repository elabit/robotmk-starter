*** Settings ***
Resource   lib-browser.resource


*** Keywords ***

Browser Init
    New Browser  headless=%{ROBOTMK_HEADLESS_HOST=false}  slowMo=1s

Session Init
    [Arguments]  ${url}
    New Context    locale=en-US
    # wait_until=commit: some pages pull in third-party trackers
    # (GTM, giscus, Wistia, ...) whose requests never settle in 
    # headless browsers, so the default "load" event never fires 
    # and times out even though every resource is reachable.
    # "commit" is the earliest event that indicates the page is 
    # ready for interaction - use this whenever needed to avoid timeouts. 
    New Page    ${url}    wait_until=commit

Take A Screenshot
    Take Screenshot  EMBED  fileType=jpeg  quality=80