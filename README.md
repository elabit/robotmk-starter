# robotmk-starter

<!-- CI-BADGE-START -->
[![Run Suites](https://github.com/YOUR_ORG/robotmk-starter/actions/workflows/run-suites.yml/badge.svg)](https://github.com/YOUR_ORG/robotmk-starter/actions/workflows/run-suites.yml)
<!-- CI-BADGE-END -->

> **Ready-to-run Robot Framework suites for [Checkmk](https://checkmk.com) synthetic monitoring with [Robotmk](https://www.robotmk.org), the [Robot Framework](https://robotframework.org/) integration for Checkmk.**

No local Python. No `pip install`. No `venv`. Just RCC and one command.

---

Whether you're setting up your first synthetic test in Checkmk or building a production-grade monitoring suite — this repo gives you a running starting point.

Two kinds of content live here:

|                  | [`examples/`](examples/)         | [`templates/`](templates/)              |
|------------------|----------------------------------|-----------------------------------------|
| **What**         | Full working suites              | Minimal skeletons                       |
| **Run it?**      | Yes, immediately                 | Not yet — fill in the TODOs first       |
| **Purpose**      | Learn by example, adapt and copy | Blank canvas for your own suite         |

---

## Suites

The tables below are auto-generated from each suite's `conda.yaml` and refreshed on every CI run.

### Examples

<!-- EXAMPLES-TABLE-START -->

| Suite | Description | Dependencies | Repo |
|---|---|---|---|
| [cryptolibrary-simple](examples/cryptolibrary-simple) | TODO | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-crypto==0.3 | [try out online](https://github.com/robotmk/example-cryptolibrary-simple) |
| [web-cryptolibrary](examples/web-cryptolibrary) | This suite shows how to perform a login with the CryptoLibrary. The encrypted password is stored in suite.robot. The private key (keys/private_key.json) allows RCC/Robotmk to decrypt it at runtime. The key password is passed via the environment variable RMKCRYPTPW. | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out online](https://github.com/robotmk/example-web-cryptolibrary) |
| [web-webshop](examples/web-webshop) | Synthetic monitoring demo – Checkout flow (no payment). Tests the full user journey: login → add items to cart → checkout. Credentials are encrypted with CryptoLibrary (key in keys/). The key password is read from RF_CRYPT_PWD (default: robotmk). | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out online](https://github.com/robotmk/example-web-webshop) |

<!-- EXAMPLES-TABLE-END -->

### Templates

<!-- TEMPLATES-TABLE-START -->

| Suite | Description | Dependencies |
|---|---|---|
| [rf-custom-library](templates/rf-custom-library) | This suite demonstrates the use of a custom library. The Keyword "Add Numbers" is defined in the custom library by a Python function. | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4 |

<!-- TEMPLATES-TABLE-END -->

---

## Prerequisites

One tool: **RCC** — the isolated environment manager that Robotmk uses internally.
RCC builds a fully reproducible Python environment from `conda.yaml` — no system Python required.

```bash
# Linux / macOS
curl -fsSL https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_linux64 \
  -o /usr/local/bin/rcc && chmod +x /usr/local/bin/rcc

# Windows (PowerShell — as Administrator)
Invoke-WebRequest https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_windows64.exe `
  -OutFile "$env:ProgramFiles\rcc.exe"
```

---

## Run an example

```bash
git clone https://github.com/YOUR_ORG/robotmk-starter.git
cd robotmk-starter

# First run: builds the environment (~2–5 min), then executes the suite
rcc task script \
  --space rf-libbrowser-libcrypto \
  --robot examples/web-webshop/robot.yaml \
  -- robot .
```

The second run reuses the cached environment — starts in seconds.

The `--space` value comes from the `.rcc` file inside each suite directory.
You can look it up with `cat examples/web-webshop/.rcc`.

### With the task runner

If you have [Task](https://taskfile.dev) installed:

```bash
task test EXAMPLE=web-webshop
```

---

## Start from a template

Templates are minimal — they contain the structure but not the logic.
Copy one, fill in your test steps, run it.

```bash
cp -r templates/rf-custom-library my-suite

# Open my-suite/ and replace the TODOs
$EDITOR my-suite/suite.robot

rcc task script --space rf --robot my-suite/robot.yaml -- robot .
```

---

## How it works

Each suite contains exactly what RCC and Robotmk need:

| File           | Purpose                                                          |
|----------------|------------------------------------------------------------------|
| `conda.yaml`   | Declares Python, pip, Node.js, and RF library versions precisely |
| `robot.yaml`   | RCC entry point: artifact dir, conda config, task definitions    |
| `.rcc`         | Identifies the shared environment (Holotree space) for this suite |

RCC's *holotree* model means suites that share the same space reuse the same
environment — the Browser library is only downloaded and built once, regardless
of how many suites use it.

### Credentials and secrets

Some examples use [CryptoLibrary](https://github.com/Snooz82/robotframework-crypto)
to store encrypted credentials in the repository. The decryption password is read
from the environment variable `RMKCRYPTPW`.

For CI, set it as a GitHub Actions secret. Locally, create a `.env` file in the
suite directory (already in `.gitignore`):

```ini
RMKCRYPTPW=your-password-here
```

---

## For maintainers

Examples and templates are generated from Copier sources in `_dev/`.
Version pins live in a single file — one edit, one `task generate`, done.

→ [_dev/README.md](_dev/README.md)
