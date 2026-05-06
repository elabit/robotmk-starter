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
| `conda.yaml` | Environment (Python `{{ python_version }}`, Browser `{{ rf_lib_browser_version }}`, Crypto `{{ rf_lib_crypto_version }}`) |
| `robot.toml` | Sets `RMKCRYPTPW` (key password) and `ROBOTMK_HEADLESS_HOST` |
| `keys/private_key.json` | Demo private key for credential decryption |
| `.devcontainer/devcontainer.json` | Devcontainer with noVNC desktop (port 6080) for headed browser testing |

## Links

- [robotframework-browser](https://robotframework-browser.org)
- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Practice Test Automation – Login page](https://practicetestautomation.com/practice-test-login/)
- [Robotmk documentation](https://robotmk.org)
- [RCC (Robocorp Command Center)](https://robocorp.com/tools/rcc)
