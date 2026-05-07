#!/bin/bash

# https://docs.checkmk.com/latest/en/agent_linux_legacy.html#unencrypted

VANILLA_DEB="/omd/sites/cmk/var/check_mk/agents/linux_deb/references/_VANILLA"

echo "▹ Installing the Checkmk agent..."

dpkg -i $VANILLA_DEB 2> /dev/null

bash /var/lib/cmk-agent/scripts/super-server/1_xinetd/setup deploy
bash /var/lib/cmk-agent/scripts/super-server/1_xinetd/setup trigger
