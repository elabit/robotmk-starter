<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://www.robotmk.org/rmk_crop_transp_w150.png">
  <source media="(prefers-color-scheme: light)" srcset="https://www.robotmk.org/rmk_crop_transp_150.png">
  <img alt="Robotmk" src="https://www.robotmk.org/rmk_crop_transp_150.png">
</picture>

<!-- CI-BADGE-START -->
[![Run Suites](https://github.com/elabit/robotmk-starter/actions/workflows/run-suites.yml/badge.svg)](https://github.com/elabit/robotmk-starter/actions/workflows/run-suites.yml)
<!-- CI-BADGE-END -->
# robotmk-starter



## What is this?

This repository provides **working examples** to learn and test [Robot Framework](https://robotframework.org/) automation - the test scripting language used by [Robotmk](https://www.robotmk.org) for *Synthetic Monitoring* in [Checkmk](https://checkmk.com).

## Choose your path:

You want to...

- ... play around with working **Robot Framework** examples?  
  → Read the [example guide](docs/example_guide.md) - *Copy/Paste the examples or try them online.*
- ... need a skeleton to start your own **Robot Framework** suite?  
  → Check out the [templates](templates/) folder - *Copy one, fill in your test steps, run it.*
- ... 🚀 want to **start a Checkmk playground** to live test **Robotmk** for Synthetic Monitoring*?  
  → Read the [Checkmk codespace documentation](docs/CMK-Codespace.md).  




## Content

### Folder "/examples"

A great starting point to **learn** from working Robot Framework test suites. 

To try them out, just click on "*try out*" which opens the repository, where you find instructions.

<!-- EXAMPLES-TABLE-START -->

| Suite | Description | Dependencies | Repo |
|---|---|---|---|
| [cryptolibrary-simple](examples/cryptolibrary-simple) | TODO | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-cryptolibrary-simple) |
| [web-cryptolibrary](examples/web-cryptolibrary) | This suite shows how to perform a login with the CryptoLibrary. The encrypted password is stored in suite.robot. The private key (keys/private_key.json) allows RCC/Robotmk to decrypt it at runtime. The key password is passed via the environment variable RMKCRYPTPW. | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-web-cryptolibrary) |
| [web-webshop](examples/web-webshop) | Synthetic monitoring demo – Checkout flow (no payment). Tests the full user journey: login → add items to cart → checkout. Credentials are encrypted with CryptoLibrary (key in keys/). The key password is read from RF_CRYPT_PWD (default: robotmk). | • nodejs==22.11.0<br>• pip==23.2.1<br>• python==3.12<br>• robotframework==7.4<br>• robotframework-browser==19.14.2<br>• robotframework-crypto==0.3 | [try out](https://github.com/robotmk/example-web-webshop) |

<!-- EXAMPLES-TABLE-END -->

---

### Folder "/templates"

These templates provide useful **skeletons** when you want to start your own Robot Framework suite.  

Each template focuses on a specific use case or integration, providing a ready-to-use structure and example test cases.

<!-- TEMPLATES-TABLE-START -->

| Suite | Description | Dependencies |
|---|---|---|
| [rf-custom-library](templates/rf-custom-library) | This suite demonstrates the use of a custom library. The Keyword "Add Numbers" is defined in the custom library by a Python function. | • pip==23.2.1<br>• python==3.12<br>• robotframework==7.4 |

<!-- TEMPLATES-TABLE-END -->

---

## For maintainers

Examples and templates are generated from Copier sources in `_dev/`.
Version pins live in a single file with packages and versions — edit, `task generate`, done.

→ [Dev documentation](_dev/README.md)


## About

Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
