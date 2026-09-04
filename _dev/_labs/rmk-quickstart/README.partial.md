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

The suite lives in `examples/web-roboland/`, as a first-class example the lab
borrows rather than owns:

```bash
cd examples/web-roboland
rcc task shell        # builds the environment on first use, then drops you into it
robot suite.robot
```

The first `rcc task shell` takes a few minutes — it is fetching a Python, Node, Robot
Framework, the Browser library and a browser, and assembling them into an environment of
their own. Every later start is seconds.

The browser opens where you can see it — on the noVNC desktop, port 6080.

## One limit worth knowing before module 2

The Checkmk in this lab is a **commercial edition, fully usable for testing** —
nobody runs this container in production, and nothing here is crippled. It has
exactly one boundary, and it is easy to walk into by accident:

**At most three Robotmk test services may be discovered.** Discover a fourth and
**all of them turn CRIT** — not the new one, all of them. Each test service also
brings roughly five keyword services with it, so the number of services grows
faster than the number of tests.

If everything suddenly goes red at once and nothing changed in the application,
count your discovered tests before you look for anything else.
