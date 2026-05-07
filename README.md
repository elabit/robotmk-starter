<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://www.robotmk.org/rmk_crop_transp_w150.png">
  <source media="(prefers-color-scheme: light)" srcset="https://www.robotmk.org/rmk_crop_transp_150.png">
  <img alt="Robotmk" src="https://www.robotmk.org/rmk_crop_transp_150.png">
</picture>

# robotmk-starter

<!-- CI-BADGE-START -->
[![Run Suites](https://github.com/elabit/robotmk-starter/actions/workflows/run-suites.yml/badge.svg)](https://github.com/elabit/robotmk-starter/actions/workflows/run-suites.yml)
<!-- CI-BADGE-END -->



> **Ready-to-run Robot Framework suites for [Checkmk](https://checkmk.com) synthetic monitoring with [Robotmk](https://www.robotmk.org), the [Robot Framework](https://robotframework.org/) integration for Checkmk.**

This repo gives you a running starting point.

## Overview

Two kinds of content live here:

|                  | [`examples/`](examples/)         | [`templates/`](templates/)              |
|------------------|----------------------------------|-----------------------------------------|
| **What**         | Full working RF suites              | Minimal skeletons                       |
| **Purpose**      | Learn by example, adapt and copy | Blank canvas for your own suite         |

The tables below are auto-generated from each suite's content and refreshed on every CI run.


## /examples

All examples are automatically deployed to individual GitHub repositories.  
Click on "*try out*" to open the example repo, where you find instructions to run it locally, in VS Code, or online in the Github Codespace.



<!-- EXAMPLES-TABLE-START -->

| Suite | Description | Dependencies | Repo |
|---|---|---|---|
| [cryptolibrary-simple](examples/cryptolibrary-simple) | TODO | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-cryptolibrary-simple) |
| [web-cryptolibrary](examples/web-cryptolibrary) | This suite shows how to perform a login with the CryptoLibrary. The encrypted password is stored in suite.robot. The private key (keys/private_key.json) allows RCC/Robotmk to decrypt it at runtime. The key password is passed via the environment variable RMKCRYPTPW. | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-web-cryptolibrary) |
| [web-webshop](examples/web-webshop) | Synthetic monitoring demo – Checkout flow (no payment). Tests the full user journey: login → add items to cart → checkout. Credentials are encrypted with CryptoLibrary (key in keys/). The key password is read from RF_CRYPT_PWD (default: robotmk). | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-web-webshop) |

<!-- EXAMPLES-TABLE-END -->

### Your Checkmk Playground: Codespace

As a **bonus**, this repo also contains a Checkmk `.devcontainer/` that spins up a full **CheckMK Pro** instance (image: `checkmk/check-mk-pro:2.5.0-daily`) with a Fluxbox/noVNC desktop.  
This is useful to play around with **Checkmk**, **Robotmk** and all the examples together in a pre-configured environment **without installing anything locally**.  
A dedicated tutorial on this will follow, stay tuned!

| Access | URL / Password |
|---|---|
| CheckMK Web UI | `http://localhost:5000/cmk/` — `cmkadmin` / `cmk` |
| noVNC Desktop | `http://localhost:6080` — password `vscode` |

- [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) 
- [Full docs](_dev/README.md#11-checkmk-devcontainer-devcontainer)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=1229554077)


---

## /templates

Templates are minimal — they contain the structure/concept but not the logic.
Copy one, fill in your test steps, run it.

<!-- TEMPLATES-TABLE-START -->

| Suite | Description | Dependencies |
|---|---|---|
| [rf-custom-library](templates/rf-custom-library) | This suite demonstrates the use of a custom library. The Keyword "Add Numbers" is defined in the custom library by a Python function. | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4 |

<!-- TEMPLATES-TABLE-END -->

---

## For maintainers

Examples and templates are generated from Copier sources in `_dev/`.
Version pins live in a single file — one edit, one `task generate`, done.

→ [_dev/README.md](_dev/README.md)
