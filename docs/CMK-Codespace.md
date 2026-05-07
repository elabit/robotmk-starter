# Using Checkmk in Codespace

[< back to README](../README.md)


![alt text](img/cmk_rmk_small.png)

## Step 1: Start Codespace

Click the "*Open in GitHub Codespaces*" badge below:


[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=1229554077)


Choose a Checkmk version (2.4 or 2.5) and set the CPUs at least to 4 (to shorten the environment creation time):

![alt text](../docs/img/codespace-cfg.png)

Wait for VS Code to open in the Browser and the Codespace to be provisioned (this can take a few minutes, especially on the first run).  
Open the **integrated terminal** to see the provisioning logs.  
Once it's done, you should see a message like this:

![alt text](../docs/img/codespace-ready.png)

## Step 2: Open Checkmk in the Browser

Switch to the "**PORTS**" tab where you can connect to the Checkmk instance by clicking on the published port: 

![alt text](../docs/img/vncport.png)

In the "noVNC" viewer page, click on "*connect*": 

![alt text](../docs/img/noVNC.png)

Right-Click on the desktop (yes, this black thing is a desktop) and choose to open "Checkmk". This will open Firefox and navigate to the Checkmk instance running in the container. The default credentials are `cmkadmin` / `cmk`:

![alt text](../docs/img/opencmk.gif)

Now yyou should see the Checmk Web UI: 

![alt text](img/cmk.png)


## Step 3: Add the Codespace host as monitoring target in Checkmk

On the left sidebar, click on "*Setup*" → "*Hosts*" → "*Add host*".

![alt text](img/setup.png)

![alt text](img/addhost.png)

Just enter the hostname `localhost` and click "*Save & run service discovery*". 

Checkmk will automatically discover some services on the Codespace host, which you can then activate:


![alt text](img/addhost_anim.gif)