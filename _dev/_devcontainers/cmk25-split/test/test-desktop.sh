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
# A browser must be there — the learner watches the test drive it.
# Through a shell: `command` is a builtin, and exec runs no shell.
ex bash -lc 'command -v firefox-esr' >/dev/null 2>&1 \
  || { echo "FAIL: no browser"; exit 1; }
echo "OK: desktop runs and systemd still has PID 1"
