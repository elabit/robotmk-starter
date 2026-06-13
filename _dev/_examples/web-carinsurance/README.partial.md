# web-carinsurance

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

Automates a full car insurance quote workflow on the [Tricentis sample application](http://sampleapp.tricentis.com/)
using [robotframework-browser](https://robotframework-browser.org) (Playwright).
Covers the complete process from vehicle and insurant data entry through product configuration, price selection, and quote submission via email.

## Test Cases

| Test Case | Description |
| --- | --- |
| `Create Quote for Car` | Fills in vehicle data, insurant details, product options, selects a price tier, and submits the quote by email |

## Key Files

- `suite.robot` — all test cases and keywords in one file
- `Resources/BrowserCommon.resource` — shared `Browser Init` keyword (headless-aware via `ROBOTMK_HEADLESS_HOST`)

## Links

### General links & Documentation

- [Tricentis Sample App](http://sampleapp.tricentis.com/)
- [robotframework-browser](https://robotframework-browser.org)
- [Robotmk Homepage](https://robotmk.org)
