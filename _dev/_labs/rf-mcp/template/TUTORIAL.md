# Tutorial: AI-Assisted Robot Framework Test Creation

## Overview

This tutorial shows how to use the prompt in [PROMPTS.md](PROMPTS.md) to generate a Robot Framework test suite with AI assistance — using either **Claude Code** or **GitHub Copilot** in VS Code.

Both tools connect to their "own" `robotmcp` MCP server instance, which provides Robot Framework-specific capabilities: keyword discovery, browser session management, DOM inspection, and test suite generation.

---

## Prerequisites

- VS Code with the `robotmcp` MCP server configured and running
- **Claude Code** extension installed, or **GitHub Copilot** extension installed
- The Checkmk instance accessible at `http://localhost:5000/cmk`

---

## Using Claude Code

### Step 1 — Verify the MCP Server Connection

Run the following command in the Claude Code terminal:

```
/mcp
```

The server `robotmcp-claude` must appear in the list with status **connected**.

### Step 2 — Open Claude Chat

Use the Claude Code chat panel in VS Code or the terminal-based chat interface.

### Step 3 — Address the MCP Server

Claude Code supports two ways to reference an MCP server in a prompt:

| Method | Syntax | Effect |
|--------|--------|--------|
| Hash reference | `#robotmcp-claude` | Scopes the prompt to that server's tools |
| Implicit invocation | *(none)* | Claude auto-discovers and calls tools as needed |

For best results, use the explicit hash reference. It ensures Claude targets the correct server and activates its workflow.

### Step 4 — Submit the Prompt

Paste the prompt from `PROMPTS.md` into the chat, prefixed with the server reference:

```
Using #robotmcp-claude: Create a Robot Framework test suite that verifies the login 
functionality of the Checkmk instance at http://localhost:5000/cmk ...
```

Claude will execute the following workflow automatically:

1. `manage_session` — initializes a browser session
2. `get_session_state` — inspects the live DOM to find real locators
3. `execute_step` — runs each interaction and validates the result
4. `build_test_suite` — generates the final `.robot` file

---

## Using GitHub Copilot

### Step 1 — Verify the MCP Server Connection

Open the **Copilot Chat** panel in VS Code (`Ctrl+Shift+I`).  
Confirm that `robotmcp-vscode` is listed as an available tool or agent.

### Step 2 — Address the MCP Server

Copilot Chat uses the `@` prefix to reference MCP agents and VS Code extensions:

| Method | Syntax | Effect |
|--------|--------|--------|
| At reference | `@robotmcp-vscode` | Directs Copilot to use that agent's tools |
| Tool selection | Via the **Tools** picker (paperclip icon) | Enables specific MCP tools manually |

### Step 3 — Submit the Prompt

Paste the prompt from `PROMPTS.md` into the Copilot Chat, prefixed with the server reference:

```
@robotmcp-vscode Create a Robot Framework test suite that verifies the login 
functionality of the Checkmk instance at http://localhost:5000/cmk ...
```

Copilot will invoke the MCP server tools as part of its response and produce the `.robot` file content inline.

---

## Expected Output

Regardless of which tool you use, the AI will produce a `.robot` file containing:

- `*** Variables ***` — URL, credentials, and locator values
- `*** Keywords ***` — reusable actions such as `Login To Checkmk` and `Open User Profile`
- `*** Test Cases ***` — all scenarios specified in the prompt
- Browser Library calls using locators derived from the live page

---

## Troubleshooting

**MCP server not listed**  
Restart VS Code and verify the server configuration in your MCP settings file.

**Element not found during execution**  
Claude will automatically call `get_session_state` to re-inspect the DOM and retry with updated locators.

**Copilot does not invoke MCP tools**  
Select tools manually via the **Tools** picker in the Copilot Chat panel before submitting the prompt.
