# web-cryptolibrary

Example combining [robotframework-browser](https://robotframework-browser.org) (Playwright) with
[robotframework-crypto](https://github.com/Snooz82/robotframework-crypto).
Shows how to safely inject an encrypted password into a web login form without ever
exposing the plaintext in suite files.

## What This Demonstrates

- Browser-based login using Playwright (`rfbrowser`) together with CryptoLibrary
- The difference between a clear-text password (negative example) and an encrypted password (recommended)
- Headless / headed switching via the `ROBOTMK_HEADLESS_HOST` environment variable
- Running a headed browser inside VS Code via the devcontainer noVNC desktop

## Test Cases

| Test Case | Description |
|---|---|
| `Login With Clear Text Password` | **Negative example** — logs in with a hardcoded plaintext password. Never do this in production. |
| `Login With CryptoLibrary` | **Recommended** — decrypts the stored `crypt:…` password at runtime and uses `Fill Secret` |

## Key Files

| File | Purpose |
|---|---|
| `suite.robot` | Two test cases on [practicetestautomation.com](https://practicetestautomation.com/practice-test-login/) |
| `conda.yaml` | Environment (Python `3.12`, Browser `19.14.2`, Crypto `0.3`) |
| `robot.toml` | Sets `RMKCRYPTPW` (key password) and `ROBOTMK_HEADLESS_HOST` |
| `keys/private_key.json` | Demo private key for credential decryption |
| `.devcontainer/devcontainer.json` | Devcontainer with noVNC desktop (port 6080) for headed browser testing |

## Links

- [robotframework-browser](https://robotframework-browser.org)
- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Practice Test Automation – Login page](https://practicetestautomation.com/practice-test-login/)
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

Install the [RobtoCode](https://marketplace.visualstudio.com/items?itemName=d-biehl.robotcode) extension for VS Code to run the robot with the integrated run/debug tools.  
**This is the recommended way for the implementation of Robot Framework suites.**

### In VS Code / Devcontainer

Just press the button below. RCC is pre-installed, will create the environment and activate it for VS Code. 
