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

### 👀 Folder "/examples"

A great starting point to **learn** from working Robot Framework test suites. 

To try them out, just click on "*try out*" which opens the repository, where you find instructions.

<!-- EXAMPLES-TABLE-START -->

| Robot Framework Suite | Description | Repository Link |
|---|---|---|
| [cryptolibrary-simple](examples/cryptolibrary-simple) | A minimalistic example of how to use the **CryptoLibrary**, without bells and whistles. | [try out](https://github.com/robotmk/example-cryptolibrary-simple) |
| [rf-custom-library](examples/rf-custom-library) | This suite demonstrates the use of a **custom library**, written with a simple Python class. | [try out](https://github.com/robotmk/example-rf-custom-library) |
| [rf-python-varfiles](examples/rf-python-varfiles) | A suite to demonstrate how to load **variables** from **Python**, **JSON** and **YAML** variable files, including nested data structures. | [try out](https://github.com/robotmk/example-rf-python-varfiles) |
| [web-carinsurance](examples/web-carinsurance) | A car insurance quote workflow on a sample application using the Browser Library. Covers the complete process from vehicle and insurant data entry through product configuration, price selection, and quote submission via email. | [try out](https://github.com/robotmk/example-web-carinsurance) |
| [web-cryptolibrary](examples/web-cryptolibrary) | A example of how to use the **CryptoLibrary** in a web test (**BrowserLibrary**). | [try out](https://github.com/robotmk/example-web-cryptolibrary) |
| [web-todomvc](examples/web-todomvc) | A simple web test on the famous todoMVC web application, with a special emphasis on the assertion after actions. | [try out](https://github.com/robotmk/example-web-todomvc) |

<!-- EXAMPLES-TABLE-END -->

---

### 🗍 Folder "/templates"

These templates provide useful **skeletons** when you want to start your own Robot Framework suite.  

Each template focuses on a specific use case or integration, providing a ready-to-use structure and example test cases.

<!-- TEMPLATES-TABLE-START -->

| Robot Framework Suite | Description |
|---|---|
| [web-browserlibrary](templates/web-browserlibrary) | A minimal skeleton to start with BrowserLibrary and Resource files. |

<!-- TEMPLATES-TABLE-END -->

---

### ⚗️ Folder "/labs"

Structured labs to learn and test Robotmk in self-contained scenarios.

To try them out, just click on "*try out*" which opens the repository, where you find instructions.

<!-- LABS-TABLE-START -->

| Robot Framework Suite | Description | Repository Link |
|---|---|---|
| [cmk12-2026](labs/cmk12-2026) | — | [try out](https://github.com/robotmk/lab-cmk12-2026) |
| [rf-mcp](labs/rf-mcp) | — | [try out](https://github.com/robotmk/lab-rf-mcp) |
| [slac2026](labs/slac2026) | — | [try out](https://github.com/robotmk/lab-slac2026) |

<!-- LABS-TABLE-END -->

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
