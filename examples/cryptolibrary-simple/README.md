# cryptolibrary-simple

Minimal example for using [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto) with Robotmk.
Demonstrates how to store an encrypted secret in a Robot Framework suite and decrypt it at runtime
using a private key file — no plaintext passwords anywhere in the codebase.

## What This Demonstrates

- Encrypting a password with `CryptoLibrary` and storing the `crypt:…` value in the suite
- Passing the key password via an environment variable (`RMKCRYPTPW`)
- Loading the private key from a file path relative to the suite

## Test Cases

| Test Case | Description |
|---|---|
| `Test Password Equality` | Decrypts an encrypted password string and asserts it equals the known plaintext |

## Key Files

| File | Purpose |
|---|---|
| `suite.robot` | Single test suite with the `Test Password Equality` test case |
| `conda.yaml` | Python environment (Python `3.12`, robotframework-crypto `0.3`) |
| `robot.toml` | Sets the `RMKCRYPTPW` environment variable consumed by CryptoLibrary |
| `keys/private_key.json` | Demo private key for decryption — replace with your own in production |
| `.devcontainer/devcontainer.json` | VS Code devcontainer with RCC pre-installed |

## Links

- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Robot Framework](https://robotframework.org)
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
| robotframework-crypto | `0.3` |

> All versions are pinned in `_dev/config/versions.env` and injected into `conda.yaml` at generation time.

## How to Run

Run with RCC (creates the isolated environment on first run):

```bash
rcc run
```

> **In the devcontainer:** RCC is pre-installed. Open the integrated terminal and run `rcc run` directly.
