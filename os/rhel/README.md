<!-- Shared os/ README skeleton. Edit this file in _dev/_shared/ — do not edit
     the generated copy. Per-instance content (package list / caveats) comes
     from README.partial.md, itself auto-generated from the Ansible role's
     task file by render_os_readme_partial.py — do not hand-edit that either. -->

# os/rhel — OS Install Verification (`rockylinux/rockylinux:10`)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/os-rhel)

A stock `rockylinux/rockylinux:10` container, provisioned with Ansible to install exactly the OS packages needed for the Robot Framework suites under `tests/` (Browser Library / Playwright) to run headless.

## Packages installed by Ansible

- `alsa-lib`
- `at-spi2-atk`
- `atk`
- `at-spi2-core`
- `cairo`
- `cups-libs`
- `dbus-libs`
- `libdrm`
- `mesa-libgbm`
- `glib2`
- `nspr`
- `nss`
- `pango`
- `libX11`
- `libxcb`
- `libXcomposite`
- `libXdamage`
- `libXext`
- `libXfixes`
- `libxkbcommon`
- `libXrandr`
- `fontconfig`
- `freetype`
- `liberation-fonts`
- `xorg-x11-fonts-Type1`

## Deviations / Caveats

- Rocky Linux 10's base+AppStream repos do not provide Xvfb, Google Noto Color Emoji, or GNU Unifont (Noto Color Emoji is available via EPEL, which this role deliberately does not enable, to stay close to a stock install). Headless Chromium does not require Xvfb to launch, so this does not block verification, but pages relying on color emoji or Unifont's broad Unicode coverage may render with fallback glyphs. Liberation fonts and scalable X fonts ARE available here, unlike SLES's free BCI image.


## How this works

Opening this folder as a devcontainer (or running it in CI via `docker run`) does two things, in order:

1. `.devcontainer/oncreate.sh` bootstraps Ansible and runs the shared `browser-deps` role to install the packages listed above.
2. `.devcontainer/postcreate.sh` then runs every Robot Framework suite under `tests/` to verify the install actually works end-to-end — not just that packages installed, but that real headless browser tests pass.

A full run log (per-step status, exact versions, this file's content again) is written to `report.md` inside the container. That file is not committed to this repo — see it after opening the devcontainer yourself, or download it from the `os-report-rhel` artifact on the upstream CI run.

## About

Also try the other [OS install targets](https://github.com/elabit/robotmk-starter#content), and the [example suites](https://github.com/elabit/robotmk-starter#content) they verify.

🪲 Found a bug or have a suggestion?
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want to get a certified professional?
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
