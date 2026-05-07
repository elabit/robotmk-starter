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
| `conda.yaml` | Python environment (Python `{{ python_version }}`, robotframework `{{ rf_version }}`) |
| `robot.yaml` | RCC task and environment configuration |

## Links

- [Robot Framework — Extending with Python](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#creating-test-libraries)
- [Robot Framework](https://robotframework.org)
- [Robotmk Homepage](https://robotmk.org)
