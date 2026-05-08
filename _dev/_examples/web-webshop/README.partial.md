# web-webshop

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

Full checkout-flow example using [robotframework-browser](https://robotframework-browser.org) and
[robotframework-crypto](https://github.com/Snooz82/robotframework-crypto), driven by the
Robotmk **multi-profile** feature.
The same suite runs once per user profile with profile-specific encrypted credentials.


- Robotmk **multi-profile** execution: one `robot.toml` defines three user profiles (`JaneDoe`, `JackHowe`, `BobSmith`)
- Per-profile `extend-variables` override `USER_EMAIL`, `USER_PASSWORD`, and `USER_NAME`
- Encrypted passwords via CryptoLibrary — `crypt:…` values stored directly in `robot.toml`
- A real checkout flow modularised across multiple keyword resource files (`Resources/`)
- Dynamic `output-dir` with a timestamp expression in `robot.toml`

## Test Cases

| Test Case | Description |
|---|---|
| `User Can Reach Checkout Page` | Logs in as the configured user, adds items to the cart, and completes checkout |

The suite is executed **three times** — once per profile (JaneDoe, JackHowe, BobSmith) — each
with its own credentials and a timestamped output directory.


## Links

### General links & Documentation

- [Practice Software Testing – Webshop](https://practicesoftwaretesting.com)
- [robotframework-browser](https://robotframework-browser.org)
- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Robotmk Homepage](https://robotmk.org)
