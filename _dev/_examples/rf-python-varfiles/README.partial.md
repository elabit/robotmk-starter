# rf-python-varfiles

{% include 'how-to-run.partial.md' %}

## About this Robot Framework test

Minimal example for loading variables and configuration into a Robot Framework suite from Python and YAML files.
Demonstrates the three variable file patterns supported by RF: plain scalars, nested dicts, and the `get_variables()` function — plus YAML as a data-format alternative to Python.


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


## Links

### Recommended links for this example
- [Robot Framework — Variable Files](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-files)

### General links & Documentation

- [Robot Framework](https://robotframework.org)
- [Robotmk Homepage](https://robotmk.org)
