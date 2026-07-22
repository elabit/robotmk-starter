<!-- Shared os/ README skeleton. Edit this file in _dev/_shared/ — do not edit
     the generated copy. Per-instance content (package list / caveats) comes
     from README.partial.md, itself auto-generated from the Ansible role's
     task file by render_os_readme_partial.py — do not hand-edit that either. -->

# os/ubuntu — OS Install Verification (`ubuntu:24.04`)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/os-ubuntu)

A stock `ubuntu:24.04` container, provisioned with Ansible to install exactly the OS packages needed for the Robot Framework suites under `tests/` (Browser Library / Playwright) to run headless.

## Packages installed by Ansible

- `libasound2t64`
- `libatk-bridge2.0-0t64`
- `libatk1.0-0t64`
- `libatspi2.0-0t64`
- `libcairo2`
- `libcups2t64`
- `libdbus-1-3`
- `libdrm2`
- `libgbm1`
- `libglib2.0-0t64`
- `libnspr4`
- `libnss3`
- `libpango-1.0-0`
- `libx11-6`
- `libxcb1`
- `libxcomposite1`
- `libxdamage1`
- `libxext6`
- `libxfixes3`
- `libxkbcommon0`
- `libxrandr2`
- `xvfb`
- `fonts-liberation`
- `fonts-noto-color-emoji`
- `fonts-unifont`
- `libfontconfig1`
- `libfreetype6`
- `xfonts-scalable`


## How this works

Opening this folder as a devcontainer (or running it in CI via `docker run`) does two things, in order:

1. `.devcontainer/oncreate.sh` bootstraps Ansible and runs the shared `browser-deps` role to install the packages listed above.
2. `.devcontainer/postcreate.sh` then runs every Robot Framework suite under `tests/` to verify the install actually works end-to-end — not just that packages installed, but that real headless browser tests pass.

A full run log (per-step status, exact versions, this file's content again) is written to `report.md` inside the container. That file is not committed to this repo — see it after opening the devcontainer yourself, or download it from the `os-report-ubuntu` artifact on the upstream CI run.

## About

Also try the other [OS install targets](https://github.com/elabit/robotmk-starter#content), and the [example suites](https://github.com/elabit/robotmk-starter#content) they verify.

🪲 Found a bug or have a suggestion?
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want to get a certified professional?
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
