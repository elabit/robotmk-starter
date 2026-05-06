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
| `conda.yaml` | Python environment (Python `{{ python_version }}`, robotframework-crypto `{{ rf_lib_crypto_version }}`) |
| `robot.toml` | Sets the `RMKCRYPTPW` environment variable consumed by CryptoLibrary |
| `keys/private_key.json` | Demo private key for decryption — replace with your own in production |
| `.devcontainer/devcontainer.json` | VS Code devcontainer with RCC pre-installed |

## Links

- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Robot Framework](https://robotframework.org)
- [Robotmk documentation](https://robotmk.org)
- [RCC (Robocorp Command Center)](https://robocorp.com/tools/rcc)
