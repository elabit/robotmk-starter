#!/usr/bin/env bash
# test-desktop.sh — the desktop must run AND systemd must keep PID 1.
#
# This is the whole reason the desktop is not a devcontainer feature:
# desktop-lite carries "init": true in its own metadata, Docker then puts tini
# at PID 1, and systemd refuses with "Couldn't find an alternative telinit
# implementation to spawn." Setting "init": false in devcontainer.json does not
# override it. Measured, see ADR-0072.
set -euo pipefail
D="$(cd "$(dirname "$0")/../template/.devcontainer" && pwd)"
docker compose -f "$D/docker-compose.yml" up -d --build host
trap 'docker compose -f "$D/docker-compose.yml" down -v' EXIT
ex() { docker compose -f "$D/docker-compose.yml" exec -T host "$@"; }

for _ in $(seq 1 45); do
  ex systemctl is-active novnc >/dev/null 2>&1 && break
  sleep 2
done

[[ "$(ex cat /proc/1/comm)" == systemd* ]] || { echo "FAIL: systemd lost PID 1"; exit 1; }
for u in vncserver fluxbox novnc; do
  a=$(ex systemctl is-active "$u" 2>&1 || true)
  [[ "$a" == active ]] || { echo "FAIL: $u is $a"; exit 1; }
done
ex bash -c 'timeout 5 bash -c "</dev/tcp/127.0.0.1/6080"' \
  || { echo "FAIL: port 6080 closed"; exit 1; }
ex bash -c 'DISPLAY=:1 xdpyinfo >/dev/null 2>&1' \
  || { echo "FAIL: no display on :1"; exit 1; }
# No assertion about a system browser: Playwright brings its own, and Checkmk is
# reached through the forwarded port. What has to hold is that X accepts a client
# at all — that is what xdpyinfo above proves.
# Port 6080 must open the viewer, not a directory listing. Debian's novnc ships
# vnc.html and no index.html, so websockify serves the folder instead.
root=$(ex bash -lc 'curl -s http://127.0.0.1:6080/')
case "$root" in
  *"Directory listing"*) echo "FAIL: 6080 shows a directory listing, not the viewer"; exit 1 ;;
esac
# The root must hand the learner on to the viewer rather than make them guess a
# filename. Do not assert on the wording of that page — assert on where it points.
echo "$root" | grep -q "vnc.html" || { echo "FAIL: / does not lead to the viewer"; exit 1; }
ex bash -lc 'curl -s http://127.0.0.1:6080/vnc.html' | grep -qi "noVNC" \
  || { echo "FAIL: /vnc.html is not the noVNC client"; exit 1; }

# A learner must be able to open a shell from the desktop.
ex bash -lc 'command -v xterm' >/dev/null 2>&1 || { echo "FAIL: no terminal emulator"; exit 1; }

# fluxbox must find a way to paint the root window, otherwise it complains on
# every start that it cannot set the wallpaper.
ex bash -lc 'command -v xsetroot' >/dev/null 2>&1 || { echo "FAIL: no xsetroot"; exit 1; }
ex test -f /root/.fluxbox/menu || { echo "FAIL: no fluxbox menu"; exit 1; }
ex grep -q "Terminal" /root/.fluxbox/menu || { echo "FAIL: menu has no Terminal entry"; exit 1; }

# The agent's <<<ps_lnx>>> section is built with `ps ax`. Without procps it comes
# up empty and the learner sees no process monitoring at all.
ex bash -lc 'ps ax >/dev/null' 2>/dev/null || { echo "FAIL: no working ps"; exit 1; }

echo "OK: desktop runs and systemd still has PID 1"
