*** Settings ***
Library     Browser
...             run_on_failure=BrowserCommon.Take A Screenshot
...             enable_playwright_debug=disabled
...             auto_delete_passed_tracing=True
...             timeout=20s