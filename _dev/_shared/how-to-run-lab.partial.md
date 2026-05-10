<!-- Lab-specific intro injected after H1 in every lab README.
     Edit this file in _dev/_shared/ — do not edit the generated copy. -->

This repository is a **Checkmk practice lab** — a hands-on environment for learning [Robotmk](https://www.robotmk.org) Synthetic Monitoring with [Checkmk](https://checkmk.com) and [Robot Framework](https://robotframework.org/).

The lab contains multiple exercise suites. Some may be intentionally incomplete — that is part of the challenge.

## How to Open the Lab

### Run in a GitHub Codespace (recommended)

Click the button below to open this lab in a fully configured VS Code environment in the browser — Checkmk, Robot Framework, Firefox, and a VNC desktop included, no local installation needed:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/{{ example_name }})

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based VS Code environment hosted by GitHub.  
> The devcontainer automatically installs Checkmk, RCC, and all RF dependencies on first start.

### Run locally with Docker

Clone this repository and open it in VS Code with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).  
VS Code will detect `.devcontainer/devcontainer.json` and prompt you to reopen in container.
