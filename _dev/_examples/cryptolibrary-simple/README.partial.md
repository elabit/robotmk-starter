# cryptolibrary-simple

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

Minimal example for using [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto) with Robotmk.  
Demonstrates how to store an encrypted secret in a Robot Framework suite and decrypt it at runtime using a private key file — no plaintext passwords anywhere in the codebase!


- Encrypting a password with `CryptoLibrary` and storing the `crypt:…` value in the suite
- Passing the key password via an environment variable (`RMKCRYPTPW`)
- Loading the private key from a file path relative to the suite

## Test Cases

| Test Case | Description |
|---|---|
| `Test Password Equality` | Decrypts an encrypted password string and asserts it equals the known plaintext |


## Links

### Recommended links for this example

- [Robotmk Blog: How to use the CryptoLibrary](https://www.robotmk.org/en/blog/cryptolibrary/)

### General links & Documentation

- [robotframework-crypto](https://github.com/Snooz82/robotframework-crypto)
- [Robot Framework](https://robotframework.org)
- [Robotmk Homepage](https://robotmk.org)
