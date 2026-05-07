#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Checkmk agent
# ---------------------------------------------------------------------------
echo ">>> Installing Checkmk agent..."
bash "$(dirname "$0")/install_cmk_agent.sh"

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


# ---------------------------------------------------------------------------
# Fluxbox menu — add Firefox entry
# ---------------------------------------------------------------------------
MENU_FILE="${HOME}/.fluxbox/menu"
if [[ -f "${MENU_FILE}" ]] && ! grep -qF "firefox" "${MENU_FILE}"; then
  sed -i '/^\[begin\]/a\  [exec] (Checkmk) {firefox-esr http://localhost:5000/cmk}' "${MENU_FILE}"
  echo ">>> Firefox added to fluxbox menu."
fi



# ---------------------------------------------------------------------------
# Fluxbox startup — set VNC resolution to 1440x900
# ---------------------------------------------------------------------------
STARTUP_FILE="${HOME}/.fluxbox/startup"
if [[ -f "${STARTUP_FILE}" ]] && ! grep -qF "xrandr --output VNC-0 --mode" "${STARTUP_FILE}"; then
  sed -i '/exec fluxbox/i xrandr --output VNC-0 --mode 1440x900' "${STARTUP_FILE}"
  echo ">>> VNC resolution set to 1440x900 in fluxbox startup."
fi

# kill and restart fluxbox to apply changes immediately
pkill fluxbox || true
fluxbox &