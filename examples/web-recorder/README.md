<!-- First include the example/template's partial. Examples include the exmaple-intro.partial in turn. -->

# web-recorder

<!-- Common intro injected after H1 in every example README.
     Edit this file in _dev/_shared/ — do not edit the generated copy. -->

This repository provides a **working example** to learn and test [Robot Framework](https://robotframework.org/) automation - the test scripting language used by [Robotmk](https://www.robotmk.org) for *Synthetic Monitoring* in [Checkmk](https://checkmk.com).

## How to Run the example

### Run online in a VS Code Devcontainer (recommended)

This is the easiest way to run the example — no local installation needed. Just click the button below:

[![Run this Robot in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/example-web-recorder)

→ [How to run the example in Codespace](https://github.com/elabit/robotmk-starter/blob/main/docs/example-guide.md)

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based development environment (VS Code) hosted by GitHub — no local installation needed.  

### Manually with RCC

To run Robot Framework suites manually, refer to the Robotmk blog post with the step-by-step instructions for RCC:
   
→ [How to Run Robot Framework Examples with RCC](https://www.robotmk.org/en/blog/rcc-efficient-python-integration/)  
→ [Troubleshooting RCC](https://www.robotmk.org/en/blog/rcctrouble/)


## About this Robot Framework test

This example shows the **Keyword Recorder** of [robotframework-browser](https://robotframework-browser.org)
(new in version 21.0.0). Instead of writing selectors by hand, you click through the application
in a real browser and the recorder writes Robot Framework keywords for you.

`suite.robot` is the starting point. It opens a browser, loads the Robotmk demo app (`${URL}`) and
then calls [`Record Keywords`](https://marketsquare.github.io/robotframework-browser/Browser.html#Record%20Keywords).
This keyword shows a recorder toolbar on the page and waits until you finish recording:

1. In the toolbar, click **Record keyword**, give the keyword a name (for example `Order Burger`) and do the steps in the app.
2. Click **Save**. The keyword goes straight into `suite.robot`, below `*** Keywords ***`, and is tagged `recorded`.
3. Record the next keyword, or end the session with **✕**.

While you record you can:

- click a value in the toolbar to turn it into a keyword argument (e.g. the text typed into the "special request" field becomes `${special_request}`),
- use **Undo** to drop the last action and **Pause** to click around without recording,
- use **Pick** to copy a selector into the keyword as a comment.

`solution.robot` shows what you get after a recording session: two recorded keywords,
`Reset Park` and `Order Burger`, and a test case that uses them.

> **Note:** The recorder needs a visible browser. It does not work in headless mode, so make sure
> `ROBOTMK_HEADLESS_HOST` is `false` (see `robot.toml`). Get your own free demo instance at
> <https://demo.robotmk.org> and set `${URL}` in the suite.

### Why record keywords, not whole test cases?

A recorder that writes a whole test case gives you one long list of clicks. It works once, but it is
hard to read and hard to maintain: if the login page changes, you have to fix it in every test that
logs in. Recording **keywords** gives you small, named building blocks instead:

- **Reuse.** `Reset Park` is used as test setup, `Order Burger` can be used in any number of tests.
- **Readable tests.** The test case says *what* happens (`Order Burger    without onions`), the keyword holds the *how* (selectors, clicks).
- **One place to fix.** When the UI changes, you record or fix one keyword, and every test that uses it works again.
- **Data-driven.** Values turned into arguments (`${special_request}`) let you run the same steps with other data.
- **You stay in control.** You still write the test cases yourself. The structure, the order and the assertions in your tests come from you, not from a click log.

Review recorded keywords before you commit them: the values come from the page, including anything
typed into password fields.

## Test Cases

| File | Test Case | Description |
| --- | --- | --- |
| `suite.robot` | `Test One` | Opens the demo app and starts a `Record Keywords` session |
| `solution.robot` | `Test One` | Resets the park (test setup) and orders a cheese burger with a special request, then checks the order total |

## Key Files

- `suite.robot` — starting point: opens the app and starts the recorder; recorded keywords are written into this file
- `solution.robot` — example result with the recorded keywords `Reset Park` and `Order Burger`
- `Resources/BrowserCommon.resource` — shared `Browser Init` keyword (headless-aware via `ROBOTMK_HEADLESS_HOST`)

## Links

### General links & Documentation

- [Robotmk demo app](https://demo.robotmk.org)
- [Browser library: Record Keywords](https://marketsquare.github.io/robotframework-browser/Browser.html#Record%20Keywords)
- [Browser library: Record Keyword](https://marketsquare.github.io/robotframework-browser/Browser.html#Record%20Keyword)
- [robotframework-browser](https://robotframework-browser.org)
- [Robotmk Homepage](https://robotmk.org)



## Libraries and Versions used in this example

| Library | Version |
|---|---|
| Python | `3.12` |
| Robot Framework | `7.5.1` |
| robotframework-browser-batteries | `21.0.0` |


## About

Also try the other [RF example suites](https://github.com/elabit/robotmk-starter#content), they all work in the Codespace environment.  

🪲 Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
