<!-- First include the example/template's partial. Examples include the exmaple-intro.partial in turn. -->

## What this lab is

The practice environment for the **Checkmk Synthetic Monitoring Quickstart**.

Two machines, on purpose:

| | |
|---|---|
| `cmk` | A Checkmk site, already installed and started |
| `host` | A plain Linux machine with systemd — where you work, and what Checkmk monitors |

In a real setup the monitoring server and the monitored host are never the same
computer, and everything from module 2 onwards depends on them being separate.

**Checkmk is preinstalled because installing Checkmk is not what this course
teaches.** Everything that is — RCC, the Checkmk agent, the Robotmk scheduler —
you install yourself, with the same commands you would use at work.

## Before you start

The test drives [Roboland](https://demo.robotmk.org), a little point-of-sale
application. You need your own workspace key; the form on that page issues one
against an e-mail address and it lasts 30 days.

Put it in the environment, never in the suite file:

```bash
export ROBOLAND_KEY=your-five-groups
```

A key pasted into `roboland.robot` gets committed by accident, and then it lives
in your repository. If the variable is missing, the test says so in plain words
instead of failing on a selector.

## Running the test

```bash
rcc task shell        # builds the environment on first use, then drops you into it
robot roboland.robot
```

The first `rcc task shell` takes a few minutes — it is fetching a Python, Node, Robot
Framework, the Browser library and a browser, and assembling them into an environment of
their own. Every later start is seconds.

The browser opens where you can see it — on the noVNC desktop, port 6080.



## Libraries and Versions used in this example

| Library | Version |
|---|---|
| Python | `3.12` |
| Node.js | `22.11.0` |
| Robot Framework | `7.4` |
| robotframework-browser | `19.14.2` |


## About

Also try the other [RF example suites](https://github.com/elabit/robotmk-starter#content), they all work in the Codespace environment.  

🪲 Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

📖 Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
