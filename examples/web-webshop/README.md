# web-webshop

Full checkout-flow example using [robotframework-browser](https://robotframework-browser.org) and
[robotframework-crypto](https://github.com/Snooz82/robotframework-crypto), driven by the
Robotmk **multi-profile** feature.
The same suite runs once per user profile with profile-specific encrypted credentials.

## What This Demonstrates

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

## Key Files

| File | Purpose |
|---|---|
| `webshop.robot` | Main suite: login → add items to cart → checkout |
| `robot.toml` | Multi-profile config with 3 user profiles and encrypted passwords |
| `conda.yaml` | Environment (Python `3.12`, Browser `19.14.2`, Crypto `0.3`) |
| `keys/private_key.json` | Demo private key for credential decryption |
| `Resources/authentication.resource` | `Login As User` keyword |
| `Resources/catalog.resource` | `Add Item To Cart` / `Add Items To Cart` keywords |
| `Resources/cart.resource` | `Open Cart` keyword |
| `Resources/checkout.resource` | `Fill Billing Address` / `Execute Payment` keywords |
| `.devcontainer/devcontainer.json` | Devcontainer with noVNC desktop for headed browser testing |

## Links

- [Practice Software Testing – Webshop](https://practicesoftwaretesting.com)
- [robotframework-browser](https://robotframework-browser.org)
- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Robotmk documentation](https://robotmk.org)
- [RCC (Robocorp Command Center)](https://robocorp.com/tools/rcc)


## Prerequisites

- **RCC** — Robocorp Command Center. Download from [robocorp.com/tools/rcc](https://robocorp.com/tools/rcc)
  or use the provided script (`_dev/scripts/download-rcc.sh` / `download-rcc.ps1`).
- **Robotmk Scheduler** — [Robotmk](https://robotmk.org) triggers and monitors the suite.
  RCC handles the isolated Python environment automatically.

## Libraries & Versions

| Library | Version |
|---|---|
| Python | `3.12` |
| Robot Framework | `7.4` |
| robotframework-browser | `19.14.2` |
| robotframework-crypto | `0.3` |

> All versions are pinned in `_dev/config/versions.env` and injected into `conda.yaml` at generation time.

## How to Run

Run with RCC (creates the isolated environment on first run):

```bash
rcc run
```

> **In the devcontainer:** RCC is pre-installed. Open the integrated terminal and run `rcc run` directly.
