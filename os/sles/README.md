<!-- Shared os/ README skeleton. Edit this file in _dev/_shared/ — do not edit
     the generated copy. Per-instance content (package list / caveats) comes
     from README.partial.md, itself auto-generated from the Ansible role's
     task file by render_os_readme_partial.py — do not hand-edit that either. -->

# os/sles — OS Install Verification (`registry.suse.com/suse/sle15:15.7`)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/os-sles)

A stock `registry.suse.com/suse/sle15:15.7` container, provisioned with Ansible to install exactly the OS packages needed for the Robot Framework suites under `tests/` (Browser Library / Playwright) to run headless.

## Packages installed by Ansible

- `libasound2`
- `libatk-bridge-2_0-0`
- `libatk-1_0-0`
- `libatspi0`
- `libcairo2`
- `libcups2`
- `libdbus-1-3`
- `libdrm2`
- `libgbm1`
- `libglib-2_0-0`
- `mozilla-nspr`
- `mozilla-nss`
- `libpango-1_0-0`
- `libX11-6`
- `libxcb1`
- `libXcomposite1`
- `libXdamage1`
- `libXext6`
- `libXfixes3`
- `libxkbcommon0`
- `libXrandr2`
- `libfontconfig1`
- `libfreetype6`
- `dejavu-fonts`
- `xorg-x11-fonts-core`

## Deviations / Caveats

- SLE_BCI (the free SLES base image) does not provide Xvfb or the exact Liberation/Noto-Color-Emoji/Unifont/scalable-X font packages available on Debian/Ubuntu. dejavu-fonts and xorg-x11-fonts-core are installed as broad-coverage substitutes -- without at least one real font, Chromium fatally crashes on any page with real text (SLE_BCI ships zero fonts by default), so this is not optional. Headless Chromium does not require Xvfb to launch. Pages relying specifically on color emoji or CJK/Unifont-level Unicode coverage may still render with fallback glyphs. A subscribed SLES image with the Package Hub/Desktop module could add the exact upstream packages; the free BCI image cannot.


## How this works

Opening this folder as a devcontainer (or running it in CI via `docker run`) does two things, in order:

1. `.devcontainer/oncreate.sh` bootstraps Ansible and runs the shared `browser-deps` role to install the packages listed above.
2. `.devcontainer/postcreate.sh` then runs every Robot Framework suite under `tests/` to verify the install actually works end-to-end — not just that packages installed, but that real headless browser tests pass.

A full run log (per-step status, exact versions, this file's content again) is written to `report.md` inside the container. That file is not committed to this repo — see it after opening the devcontainer yourself, or download it from the `os-report-sles` artifact on the upstream CI run.

## About

Also try the other [OS install targets](https://github.com/elabit/robotmk-starter#content), and the [example suites](https://github.com/elabit/robotmk-starter#content) they verify.

🪲 Found a bug or have a suggestion?
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want to get a certified professional?
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
