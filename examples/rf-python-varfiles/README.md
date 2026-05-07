# rf-python-varfiles

Minimal example for loading variables and configuration into a Robot Framework suite from Python and YAML files.
Demonstrates the three variable file patterns supported by RF: plain scalars, nested dicts, and the `get_variables()` function — plus YAML as a data-format alternative to Python.

## What This Demonstrates

- Exposing computed scalar values (e.g. current user, timestamp) from a Python variable file
- Accessing values from a nested dict loaded via a Python variable file using the `[key]` subscript syntax
- Loading a nested data structure from a YAML variable file (same access syntax as Python dicts)
- Using a `get_variables(arg)` function to return different variable sets depending on an argument passed at import time
- Selecting an environment config block at runtime by combining a suite variable with a nested dict key

## Test Cases

| Test Case | Description |
|---|---|
| `Test Pyvars-Simple` | How to expose simple scalar values from a Python file as suite variables |
| `Test Pyvars-Nested` | How to access individual values from a nested dict loaded via a Python variable file |
| `Test YML-Nested` | How to load a nested data structure from a YAML variable file |
| `Test Get-Variables With Argument` | How to use `get_variables()` to return different variable sets based on an argument passed at import time |

## Key Files

| File | Purpose |
|---|---|
| `suite.robot` | Suite importing all four variable files and demonstrating each pattern |
| `Data/pyvars-simple.py` | Plain variable file with computed scalars (user, timestamp, random int) |
| `Data/pyvars-nested.py` | Nested environment config dict (`dev` / `test` / `prod`) |
| `Data/ymlvars-nested.yaml` | Same environment config structure as a YAML variable file |
| `Data/pyvars-getvariables.py` | `get_variables(browser)` returning browser-specific config profiles |
| `conda.yaml` | Python environment (Python `3.12`, robotframework `7.4`) |
| `robot.yaml` | RCC task and environment configuration |

## Links

- [Robot Framework — Variable Files](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-files)
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
