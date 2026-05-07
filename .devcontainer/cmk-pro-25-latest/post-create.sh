#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Checkmk agent
# ---------------------------------------------------------------------------
echo ">>> Installing Checkmk agent..."
bash "$(dirname "$0")/install_cmk_agent.sh" vanilla

# ---------------------------------------------------------------------------
# Firefox
# ---------------------------------------------------------------------------
# 'firefox-esr' is a Debian package — not in Ubuntu's default repos.
# Ubuntu's 'firefox' apt package is a snap stub that fails inside containers.
# Solution: Mozilla's PPA ships firefox-esr as a proper .deb for Ubuntu.

echo ">>> Installing Firefox via Mozilla PPA..."
apt-get update -qq
apt-get install -y --no-install-recommends software-properties-common
add-apt-repository -y ppa:mozillateam/ppa

# Pin PPA above Ubuntu's snap redirect (priority 1001 > default 500)
cat > /etc/apt/preferences.d/mozilla-firefox <<'EOF'
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF

apt-get update -qq
apt-get install -y --no-install-recommends firefox-esr

bash "$(dirname "$0")/fluxbox-cfg.sh"