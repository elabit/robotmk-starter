# rf-custom-library

Minimal example for extending Robot Framework with a custom Python library.
Demonstrates how to write a simple Python class, expose its methods as keywords via the `@keyword` decorator, and import the library directly into a suite.

## What This Demonstrates

- Writing a custom Robot Framework library as a plain Python class (`CustomLibrary.py`)
- Exposing Python methods as RF keywords with `@keyword` from `robot.api.deco`
- Importing a local `.py` file as a library in a suite (`Library  CustomLibrary.py`)
- Handling type conversion for keyword arguments (string → int)

## Test Cases

| Test Case | Description |
|---|---|
| `Test Hello` | Calls the `Say Hello` keyword and logs a greeting |
| `Test Addition` | Calls `Add Numbers` with two integers and logs the result |

## Key Files

| File | Purpose |
|---|---|
| `suite.robot` | Suite importing `CustomLibrary.py` with two test cases |
| `CustomLibrary.py` | Custom library with `Say Hello` and `Add Numbers` keywords |
| `conda.yaml` | Python environment (Python `3.12`, robotframework `7.4`) |
| `robot.yaml` | RCC task and environment configuration |

## Links

- [Robot Framework — Extending with Python](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#creating-test-libraries)
- [Robot Framework](https://robotframework.org)
- [Robotmk Homepage](https://robotmk.org)


## Prerequisites

**RCC**  to create isolated self contained environments. Download from the [Robotmk release page](https://github.com/elabit/robotmk/releases/download/v4.0.0/) or use the provided script (`_dev/scripts/download-rcc.sh` / `download-rcc.ps1`).
  
## Libraries & Versions

| Library | Version |
|---|---|
| Python | `3.12` |
| Robot Framework | `7.4` |



## How to Run

### On the console

Run directly with RCC (creates the isolated environment on first run):

```bash
rcc task script --robot robot.yaml -- robot suite.robot
```

### In VS Code / Locally

Create and activate the environment, then open VS Code from the activated environment: 

```bash
rcc task shell
code . 
```

Install the [RobotCode](https://marketplace.visualstudio.com/items?itemName=d-biehl.robotcode) extension for VS Code to run the robot with the integrated run/debug tools.  
**This is the recommended way for the implementation of Robot Framework suites.**

### In VS Code / Devcontainer

Just press the button below. RCC is pre-installed, will create the environment and activate it for VS Code. 

## Closing Notes

Also try the other RF example suites, they all work in the Codespace environment.  

This is only the beginning of the journey, there is a lot more to explore in the world of Robot Framework, Robotmk and Checkmk.  

If you want to learn more, there are several ways of how we can support you:

- [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en)
- Implementing a **Robotmk POC** in your company
- Know How Transfer
- Code Review of existing Tests & Coaching Sessions
- "Extended Workbench" - We work together on your test automation projects for a defined period of time

Reach out to us via mail at robotmk.org or book a free [clarification call](https://meet.brevo.com/simon-meggle).

**Simon Meggle**  
*CEO Elabit GmbH*  
*Founder of Robotmk*  
*Product Manager of Synthetic Monitoring at Checkmk*
