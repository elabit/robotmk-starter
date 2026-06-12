# web-todomvc

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

A focused web automation example using [robotframework-browser](https://robotframework-browser.org) (Playwright),
testing the well-known [TodoMVC](https://todomvc.com) application.

The suite deliberately emphasises **assertion after every action** — each keyword verifies
the expected DOM state before returning, rather than relying on implicit waits alone.
XPath is used to target elements by their visible text, which keeps selectors readable
and resilient to minor markup changes.

## Test Cases

| Test Case | Description |
| --- | --- |
| `Todo Can Be Created` | Adds a new todo item and verifies it appears in the list |
| `Todo Can Be Deleted` | Adds a todo, deletes it via hover → click, and asserts it is gone |
| `Todo Can Be Checked Off` | Adds a todo and marks it as completed; checks the checkbox state |
| `Show Only Active Items` | Adds multiple todos, checks one off, activates the Active filter, and verifies the completed item is hidden |

## Key Files

- `suite.robot` — all test cases and keywords in one file
- `Resources/BrowserCommon.resource` — shared `Browser Init` keyword (headless-aware via `ROBOTMK_HEADLESS_HOST`)

## Links

### General links & Documentation

- [TodoMVC — Vue.js demo](https://todomvc.com/examples/vue/dist/)
- [robotframework-browser](https://robotframework-browser.org)
- [Robotmk Homepage](https://robotmk.org)
