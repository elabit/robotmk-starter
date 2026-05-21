# PROMPTS for RF-MCP

This is a collection of prompts that can be used in the RF-MCP Lab. They are designed to help you get started with the Robot Framework MCP-Server and to guide you through the process of creating, refactoring, and debugging your Robot Framework tests with the help of AI.

## Checkmk Login 

Create a Robot Framework test suite cmk.robot that verifies the login functionality of the Checkmk instance provided in this lab. The test should cover the following scenarios:

**Steps:**

- Open the Checkmk login page: http://localhost:5000/cmk
- Login with the following credentials:
  - Username: cmkadmin
  - Password: cmk
- Verify that you have successfully logged in: 
  - Open the user profile on the left 
  - Verify that the Username is correct
  - Assert that the Language is set to English

**Guardrails:**

- Use the robotmcp-claude/vscode MCP server for the creation
- Implement the whole suite, validate each step
- Use Variables for common values (e.g., username, password, URL,...).
- Use Browser Library (start browser with UI)
- Create User Keywords for reusable actions (e.g., login, navigate to profile).
