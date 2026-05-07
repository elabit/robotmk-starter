# web-browserlibrary


## What This Template Provides

A minimal, ready-to-use skeleton for web UI testing with the Robot Framework Browser Library (Playwright).

- Pre-wired Resource file layout (`lib-browser.resource`, `BrowserCommon.resource`)
- Screenshot on failure via `run_on_failure`
- Headless / headed switching via the `ROBOTMK_HEADLESS_HOST` environment variable
- One placeholder test case to fill in

## Test Cases

| Test Case | Description |
|---|---|
| `Test One` | Placeholder — replace with your actual test logic |

## Key Files

| File | Purpose |
|---|---|
| `suite.robot` | Skeleton suite with `Suite Setup` / `Test Setup` pattern and a placeholder test |
| `Resources/lib-browser.resource` | Imports `Browser` with `Take A Screenshot` on failure and Playwright tracing |
| `Resources/BrowserCommon.resource` | Shared keywords: `Browser Init`, `Session Init`, `Take A Screenshot` |
| `conda.yaml` | Environment (Python `{{ python_version }}`, Browser `{{ rf_lib_browser_version }}`, Node.js `{{ nodejs_version }}`) |
| `robot.toml` | Sets `ROBOTMK_HEADLESS_HOST=false` (show browser locally; Robotmk overrides on the host) |

## Links

- [robotframework-browser](https://robotframework-browser.org)
- [Robotmk Homepage](https://robotmk.org)
