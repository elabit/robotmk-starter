#!/bin/bash
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later
# This file is part of the Robotmk project (https://www.robotmk.org)

# This script gets executed as a hook after the Docker entrypoint script has 
# created the OMD site.  
# Note: the agent installed here has no relation to the CMK version in this container. 
# As agent installers are only available after the first login into the site, 
# we do not have access to them. Instead, a recent deb gets installed. Will work
# for most needs...  
# As soon as the first installer has been baken by the bakery, the agent will 
# anyhow have a version from the CMK server.  

VANILLA_DEB="/omd/sites/cmk/var/check_mk/agents/linux_deb/references/_VANILLA"

echo "▹ Installing the Checkmk agent..."

dpkg -i $VANILLA_DEB 2> /dev/null

bash /var/lib/cmk-agent/scripts/super-server/1_xinetd/setup deploy
bash /var/lib/cmk-agent/scripts/super-server/1_xinetd/setup trigger
