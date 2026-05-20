<!-- First include the example/template's partial. Examples include the exmaple-intro.partial in turn. -->

# RF-MCP Lab - Say it, test it, ship it!

## About this Repository

Here you can play around with the Robot Framework [MCP-Server](https://github.com/manykarim/rf-mcp/tree/main/docker) which helps you to implement, refactor and debug your [Robot Framework](https://robotframework.org/) tests **with the help of AI**.  
To have something to test against, we have set up a [Checkmk](https://checkmk.com) instance, in which you can also use [Robotmk](https://www.robotmk.org) to integrate the tests into a monitoring instance. 

### MCP Server Support

We provide MCP server support both for **VS Code** and **Claude**. You can choose which one you want to use, or even use both in parallel.

Support for **GitHub Copilot** is currently built-in. You can mention the MCP server via `#robotmcp-vscode` in your prompts. 

If you want to use **Claude**, install the [Claude Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude).  
After logging in, the Claude command `/mcp` should list the MCP-Server "robotmcp-claude".


## How to Open the Lab

### Run in a GitHub Codespace (recommended)

Click the button below to open this lab in a fully configured VS Code environment in the browser — Checkmk, Robot Framework, Firefox, and a VNC desktop included, no local installation needed:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/rfmcp)

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based VS Code environment hosted by GitHub.  
> The devcontainer automatically installs Checkmk, RCC, and all RF dependencies on first start.

### Run locally with Docker

Clone this repository and open it in VS Code with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).  
VS Code will detect `.devcontainer/devcontainer.json` and prompt you to reopen in container.


## Links

TBD


## Libraries and Versions used in this example

| Library | Version |
|---|---|
| Python | `3.12` |
| Node.js | `22.11.0` |
| Robot Framework | `7.4` |
| robotframework-browser | `19.14.2` |
| rf-mcp | `0.31.2` |


## About

Also try the other [RF example suites](https://github.com/elabit/robotmk-starter#content), they all work in the Codespace environment.  

🪲 Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
