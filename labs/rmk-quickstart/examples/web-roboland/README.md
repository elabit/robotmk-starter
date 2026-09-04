<!-- First include the example/template's partial. Examples include the exmaple-intro.partial in turn. -->

# web-roboland

<!-- Common intro injected after H1 in every example README.
     Edit this file in _dev/_shared/ — do not edit the generated copy. -->

This repository provides a **working example** to learn and test [Robot Framework](https://robotframework.org/) automation - the test scripting language used by [Robotmk](https://www.robotmk.org) for *Synthetic Monitoring* in [Checkmk](https://checkmk.com).

## How to Run the example

### Run online in a VS Code Devcontainer (recommended)

This is the easiest way to run the example — no local installation needed. Just click the button below:

[![Run this Robot in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robotmk/example-web-roboland)

→ [How to run the example in Codespace](https://github.com/elabit/robotmk-starter/blob/main/docs/example-guide.md)

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based development environment (VS Code) hosted by GitHub — no local installation needed.  

### Manually with RCC

To run Robot Framework suites manually, refer to the Robotmk blog post with the step-by-step instructions for RCC:
   
→ [How to Run Robot Framework Examples with RCC](https://www.robotmk.org/en/blog/rcc-efficient-python-integration/)  
→ [Troubleshooting RCC](https://www.robotmk.org/en/blog/rcctrouble/)


## This example belongs to a course

It is the suite learners run in **[Robotmk Academy's Checkmk Synthetic Monitoring
Quickstart](https://academy.robotmk.org)** — the first test they see, before they
have written a line themselves. The course carries it from here all the way into
Checkmk, so **the shape of this file is part of the teaching material**: it is
read line by line in module 3, changed in module 4, and extended in module 5.

If you change it, change it knowing that.

## What it does

It asks one question, the way a guest would ask it: **can somebody still buy a
burger?**

The target is [Roboland](https://demo.robotmk.org), a point-of-sale application
for an amusement park, built for exactly this purpose. The suite opens the order
counter, clicks an item, enters cash, submits, and checks that the order really
got a number.

Four lines in the test case, each one a sentence you can read aloud. That is
deliberate — a first example that needs explaining is not a first example.

## Why it is written the way it is

**The key comes from the environment, never from the file.** `roboland.robot` is
checked into a repository, and a key pasted into it gets committed the first time
somebody is not paying attention. If `ROBOLAND_KEY` is missing, the suite says so
in plain words rather than failing on a selector ten seconds later.

```bash
export ROBOLAND_KEY=your-five-groups      # free at https://demo.robotmk.org
```

**The browser is visible.** `${HEADLESS}` is `False`, because the point of the
first run is watching it happen. Checkmk will run it headless later.

**It resets the workspace before it orders.** Without that, the booth slowly runs
out of buns, orders get blocked, and the test turns red while the application is
perfectly healthy. Real applications rarely offer a reset button — the course
comes back to what you do then.

## What it proves that a ping does not

It fails when the *journey* fails. A counter whose page loads, whose total adds
up, and whose button quietly does nothing will fail here — and that is precisely
the outage the course opens with.



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
