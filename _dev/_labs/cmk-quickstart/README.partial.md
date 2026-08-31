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
rcc run
```

The browser opens where you can see it — on the noVNC desktop, port 6080.
