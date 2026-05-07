#!/bin/bash
set -euo pipefail


# ---------------------------------------------------------------------------
# Fluxbox menu — add Firefox entry
# ---------------------------------------------------------------------------
echo ">>> Configuring Fluxbox Menu..."
MENU_FILE="${HOME}/.fluxbox/menu"
if [[ -f "${MENU_FILE}" ]] && ! grep -qF "firefox" "${MENU_FILE}"; then
  sed -i '/^\[begin\]/a\  [exec] (Checkmk) {firefox-esr http://localhost:5000/cmk}' "${MENU_FILE}"
  echo ">>> Firefox added to fluxbox menu."
fi



# ---------------------------------------------------------------------------
# Fluxbox startup — set VNC resolution to 1600x1200
# ---------------------------------------------------------------------------
echo ">>> Setting Desktop resolution..."
STARTUP_FILE="${HOME}/.fluxbox/startup"
#if [[ -f "${STARTUP_FILE}" ]] && ! grep -qF "xrandr --output VNC-0 --mode" "${STARTUP_FILE}"; then
if [[ -f "${STARTUP_FILE}" ]] ; then
  sed -i '/exec fluxbox/i xrandr --output VNC-0 --mode 1600x1200' "${STARTUP_FILE}"
  echo ">>> VNC resolution set to 1600x1200 in fluxbox startup."
fi

# kill and restart fluxbox to apply changes immediately
echo ">>> Restaring Fluxbox ..."
pkill fluxbox || true
nohup fluxbox >/dev/null 2>&1 &
disown