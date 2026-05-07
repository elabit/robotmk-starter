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
| `conda.yaml` | Environment (Python `3.12`, Browser `19.14.2`, Node.js `22.11.0`) |
| `robot.toml` | Sets `ROBOTMK_HEADLESS_HOST=false` (show browser locally; Robotmk overrides on the host) |

## Links

- [robotframework-browser](https://robotframework-browser.org)
- [Robotmk Homepage](https://robotmk.org)


## Prerequisites

**RCC**  to create isolated self contained environments. Download from the [Robotmk release page](https://github.com/elabit/robotmk/releases/download/v4.0.0/) or use the provided script (`_dev/scripts/download-rcc.sh` / `download-rcc.ps1`).
  
## Libraries & Versions

| Library | Version |
|---|---|
| Python | `3.12` |
| Node.js | `22.11.0` |
| Robot Framework | `7.4` |
| robotframework-browser | `19.14.2` |
| robotframework-crypto | `0.3` |



## How to Run

### On the console

Run directly with RCC (creates the isolated environment on first run):

```bash
rcc task script --robot robot.yaml -- robot suite.robot
```

### In VS Code / Locally

Create and activate the environment, then open VS Code from the activated environment: 

```bash
rcc task shell
code . 
```

Install the [RobotCode](https://marketplace.visualstudio.com/items?itemName=d-biehl.robotcode) extension for VS Code to run the robot with the integrated run/debug tools.  
**This is the recommended way for the implementation of Robot Framework suites.**

### In VS Code / Devcontainer

Just press the button below. RCC is pre-installed, will create the environment and activate it for VS Code. 

## Closing Notes

Also try the other RF example suites, they all work in the Codespace environment.  

This is only the beginning of the journey, there is a lot more to explore in the world of Robot Framework, Robotmk and Checkmk.  

If you want to learn more, there are several ways of how we can support you:

- [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en)
- Implementing a **Robotmk POC** in your company
- Know How Transfer
- Code Review of existing Tests & Coaching Sessions
- "Extended Workbench" - We work together on your test automation projects for a defined period of time

Reach out to us via mail at robotmk.org or book a free [clarification call](https://meet.brevo.com/simon-meggle).

**Simon Meggle**  
*CEO Elabit GmbH*  
*Founder of Robotmk*  
*Product Manager of Synthetic Monitoring at Checkmk*
