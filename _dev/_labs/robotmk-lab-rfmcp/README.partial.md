# RF-MCP Lab - Say it, test it, ship it!

## About this Repository

Here you can play around with the Robot Framework [MCP-Server](https://github.com/manykarim/rf-mcp/tree/main/docker) which helps you to implement, refactor and debug your [Robot Framework](https://robotframework.org/) tests **with the help of AI**.  
To have something to test against, we have set up a [Checkmk](https://checkmk.com) instance, in which you can also use [Robotmk](https://www.robotmk.org) to integrate the tests into a monitoring instance. 

### MCP Server Support

We provide MCP server support both for **VS Code** and **Claude**. You can choose which one you want to use, or even use both in parallel.

Support for **GitHub Copilot** is currently built-in. You can mention the MCP server via `#robotmcp-vscode` in your prompts. 

If you want to use **Claude**, install the [Claude Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude).  
After logging in, the Claude command `/mcp` should list the MCP-Server "robotmcp-claude".

{% include 'how-to-run-lab.partial.md' %}

## Links

TBD