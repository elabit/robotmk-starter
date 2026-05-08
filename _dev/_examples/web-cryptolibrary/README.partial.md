# web-cryptolibrary

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

Example combining [robotframework-browser](https://robotframework-browser.org) (Playwright) with
[robotframework-crypto](https://github.com/Snooz82/robotframework-crypto).
Shows how to safely inject an encrypted password into a web login form without ever
exposing the plaintext in suite files.


- Browser-based login using Playwright (`rfbrowser`) together with CryptoLibrary
- The difference between a clear-text password (negative example) and an encrypted password (recommended)
- Headless / headed switching via the `ROBOTMK_HEADLESS_HOST` environment variable
- Running a headed browser inside VS Code via the devcontainer noVNC desktop

## Test Cases

| Test Case | Description |
|---|---|
| `Login With Clear Text Password` | **Negative example** — logs in with a hardcoded plaintext password. Never do this in production. |
| `Login With CryptoLibrary` | **Recommended** — decrypts the stored `crypt:…` password at runtime and uses `Fill Secret` |


## Links

### Recommended links for this example

- [Robotmk Blog: How to use the CryptoLibrary](https://www.robotmk.org/en/blog/cryptolibrary/)

### General links & Documentation

- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [robotframework-browser](https://robotframework-browser.org)
- [Practice Test Automation – Login page](https://practicetestautomation.com/practice-test-login/)
- [Robotmk Homepage](https://robotmk.org)