# Using Checkmk/Robotmk in a Github Codespace

[< back to README](../README.md)


![alt text](img/cmk_rmk_small.png)

> **What is a GitHub Codespace?**  
> A Codespace is a browser-based development environment (VS Code) hosted by GitHub — no local installation needed. You can run codespace environment up to 60 hours for free per month. It’s a great way to quickly test and play around with Code without the need to set up a local environment.

## Step 1: Start Codespace

Click the "*Open in GitHub Codespaces*" badge below:


[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=1229554077)


Choose a Checkmk version (2.4 or 2.5) and set the CPUs at least to 4 (to shorten the environment creation time):

![alt text](../docs/img/codespace-cfg.png)

### Startup Checklist

**Don't proceed to the next section until the environment is fully built.** Have an eye on the following things:

Wait for the web version of VS Code to open. 

Click on "*Building Codespace*" to see the build log in the integrated terminal:

![alt text](img/build-log.png)

Close all messages about open ports like these: 

![alt text](img/vscode-openport.png)

After some time, in the **integrated terminal**, you should see a message like this:

![alt text](../docs/img/codespace-ready.png)

## Step 2: Start VNC, open Checkmk in the Browser

Switch to the "**PORTS**" tab where you can connect to the Checkmk instance by clicking on the published port: 

![alt text](../docs/img/vncport.png)

In the "noVNC" viewer page, click on "*connect*": 

![alt text](../docs/img/noVNC.png)

Right-Click on the desktop (yes, this *is* a desktop) and choose to open "Checkmk". This will open Firefox and navigate to the Checkmk instance running in the container. The default credentials are `cmkadmin` / `cmk`:

![alt text](../docs/img/opencmk.gif)

Now you should see the Checkmk Web UI: 

![alt text](img/cmk.png)


## Step 3: Add the Codespace host as monitoring target in Checkmk

On the left sidebar, click on "*Setup*" → "*Hosts*" → "*Add host*".

![alt text](img/setup.png)

![alt text](img/addhost.png)

Just enter the hostname `localhost` and click "*Save & run service discovery*". 

Checkmk will automatically discover some services on the Codespace host, which you can then activate:


![alt text](img/addhost_anim.gif)

## Step 4: Configure the Robotmk Scheduler

In the *Setup* menu, search for "*Robotmk Scheduler (Linux)*" and add a new rule: 

![alt text](img/setup-scheduler.png)

In the following, the mandatory fields are: 

![alt text](img/bakery1.png)


1. ***Base Directory***: Where the Robot Framework suites (organized in folders) are located. In this case, it's `/workspaces/robotmk-starter/examples/` (the workspace is mounted in the container at the same path).
2. ***Sequence Interval***: You can configure multiple sequences with different intervals. Plans inside a sequence will be executed in the defined order (sequentially).
3. ***Application Name***: The name of the application you are testing. Will be available as a service label in the discovered services. 
4. ***Relative path to test suite***: The relative path to the test suite **suite.robot** within the *Base Directory*.
5. ***robot.yaml***: Similar to the *suite file*, this path is relative to the *Base Directory* and points to the `robot.yaml` file that defines the file the Scheduler uses to create the individual environments. 

**Hint:** For step 1, 4 and 5 it helps to copy the full path to the folder in VS Code: 

![alt text](img/copypath.png)


Lastly, it isn’t strictly necessary on this instance, but in a production environment you must remember to restrict the rule to only those hosts on which the RobotMK Scheduler is supposed to run the tests:

![alt text](img/condition.png)

After that, click on "*Save*".

## Step 5: Bake the Checkmk Agent

The fastest way to get from here to the ***Agent Bakery*** is to click on *Related* → *Agents*:

![alt text](img/gotoagent.png)

In the bakery, the orange button *Bake agents* creates the agent package for the specific host(s). 

![alt text](img/bake.png)

## Step 6: Install the Checkmk Agent

```bash
> bash /workspaces/robotmk-starter/.devcontainer/cmk-cloud-24-latest/install_cmk_agent.sh
```

This installs the agent for the host **localhost** and starts the scheduler.  
(Note: systemd is missing on the docker container, the way the scheduler is started is a bit hacky, but it works for demo purposes. In production, the scheduler gets started automatically.)

Wait some minutes so that the scheduler can create the runtime environment and execute the test suite for the first time.

## Step 7: Discover the Robotmk Service in Checkmk

The service "*Check_MK Discovery*" will change its state to **WARN** as soon as Checkmk has received the first test result from the Robotmk Scheduler:  

![alt text](img/disc_warn.png)

From the hamburger menu of the service, click on "*Run service discovery*"

![alt text](img/disc_run.png)

Checkmk should discover now **3 more services**: 

1. **RMK Scheduler Status**: Shows the status of the scheduler
2. **RMK Plan**: The overall statius of the plan (=whether Robotmk was able to run the suite at all - regardless of th results of the test cases
3. **RMK Test Case**: One service per test case, showing the result of the test case (OK/WARN/CRIT)

Click on *Accept All* and save the configuration:


![alt text](img/disc_result.png)

Finally, you will see the three services with an UNKNOWN state in the list of services.  
Trigger a new execution of the agent which returns the test results to Checkmk:

Voila, you have successfully run your first Robot Framework suite with Robotmk in Checkmk, all within a GitHub Codespace!

---


## About

Found a bug or have a suggestion?  
→ [Open an issue](https://github.com/robotmk/robotmk-starter/issues) or submit a [pull request](https://github.com/robotmk/robotmk-starter/pulls) — contributions are welcome.

Want to go deeper? Want ot get a certified professional?  
→ I offer [Synthetic Monitoring Trainings](https://lp.robotmk.org/robotmk-masterclass-4d-en) or book a free [call](https://meet.brevo.com/simon-meggle).

**Simon Meggle** — Founder of Robotmk, Product Manager Synthetic Monitoring at Checkmk
