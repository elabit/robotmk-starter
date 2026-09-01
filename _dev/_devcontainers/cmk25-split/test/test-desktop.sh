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
docker compose -f "$D/docker-compose.yml" up -d --build
trap 'docker compose -f "$D/docker-compose.yml" down -v' EXIT
ex() { docker compose -f "$D/docker-compose.yml" exec -T host "$@"; }

for _ in $(seq 1 60); do
  ex bash -lc 'curl -s -o /dev/null --max-time 3 http://127.0.0.1:6080/' 2>/dev/null && break
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
root=$(ex bash -lc 'curl -s http://127.0.0.1:6080/' || true)
case "$root" in
  *"Directory listing"*) echo "FAIL: 6080 shows a directory listing, not the viewer"; exit 1 ;;
esac
# The root must hand the learner on to the viewer rather than make them guess a
# filename. Do not assert on the wording of that page — assert on where it points.
case "$root" in
  *vnc.html*) : ;;
  *) echo "FAIL: / does not lead to the viewer"; exit 1 ;;
esac
# Fetch first, match second. Piping curl into `grep -q` looks tidy and is a trap:
# grep exits at the first match, curl gets SIGPIPE, and `set -o pipefail` turns
# the success into a failure. The check fails precisely when it should pass.
viewer=$(ex bash -lc 'curl -s http://127.0.0.1:6080/vnc.html' || true)
case "$viewer" in
  *noVNC*|*noVNC_*) : ;;
  *) echo "FAIL: /vnc.html is not the noVNC client"; exit 1 ;;
esac

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

# Checkmk must answer on localhost INSIDE this container, or Codespaces will not
# forward it: the "service:port" form of forwardPorts is dropped there.
# Every command substitution here gets a fallback. Under `set -e` an assignment
# takes the exit status of what it runs, so a curl that cannot connect does not
# just yield an empty string — it kills the script.
c=000
for _ in $(seq 1 240); do
  c=$(ex bash -lc "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:5000/cmk/" 2>/dev/null) || c=000
  [ -n "$c" ] || c=000
  [ "$c" != "000" ] && break
  sleep 5
done
[ "$c" != "000" ] || {
  echo "FAIL: Checkmk never answered on localhost:5000 within 20 minutes."
  echo "      Not an assertion about behaviour — the site simply did not come up."
  exit 1
}

# The port must not exist while nothing is behind it: an open port with no
# answer is what a forwarding proxy reports as 502.
docker compose -f "$D/docker-compose.yml" stop cmk >/dev/null 2>&1
sleep 3
docker compose -f "$D/docker-compose.yml" restart host >/dev/null 2>&1
sleep 20
if ex bash -lc 'timeout 3 bash -c "</dev/tcp/127.0.0.1/5000"' 2>/dev/null; then
  echo "FAIL: port 5000 is open while Checkmk is down — that is a 502 waiting to happen"
  docker compose -f "$D/docker-compose.yml" start cmk >/dev/null 2>&1
  exit 1
fi
docker compose -f "$D/docker-compose.yml" start cmk >/dev/null 2>&1

# Wait for the port to come back. The check above deliberately left it closed,
# and anything asked before it reopens answers nothing — which reads like a
# failed assertion but is only an impatient one.
back=000
for _ in $(seq 1 240); do
  back=$(ex bash -lc "curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1:5000/cmk/" 2>/dev/null) || back=000
  [ -n "$back" ] || back=000
  [ "$back" != "000" ] && break
  sleep 5
done
[ "$back" != "000" ] || { echo "FAIL: port 5000 never came back after restarting cmk"; exit 1; }

# cmk-shell must land in the Checkmk container, not merely exist. Asserting that
# the docker client is installed would pass while the socket is unmounted.
site=$(ex bash -lc 'cmk-shell omd version 2>&1 | head -1' || true)
case "$site" in
  *OMD*|*version*) : ;;
  *) echo "FAIL: cmk-shell did not reach the Checkmk container: $site"; exit 1 ;;
esac

# The redirect must be RELATIVE whatever Host arrives. GitHub forwarding sends
# "Host: localhost:5000", and an absolute redirect built from that points at the
# learner's own machine — which is exactly what broke the lab twice.
for spec in "localhost:5000|/" "localhost:5000|/cmk/" "anything-5000.app.github.dev|/" "anything-5000.app.github.dev|/cmk/"; do
  h=${spec%%|*}; path=${spec#*|}
  loc=$(ex bash -lc "curl -s -o /dev/null -D - -H 'Host: $h' http://127.0.0.1:5000$path | grep -i '^location' | tr -d '\r'" || true)
  case "$loc" in
    *"Location: /cmk/check_mk/"*) : ;;
    *) echo "FAIL: bad redirect for Host $h path $path -> $loc"; exit 1 ;;
  esac
done

# Checkmk must NOT be published on the machine. If it is, Codespaces forwards
# that port straight to Apache and the proxy in this container is bypassed —
# which is what made every redirect absolute and unusable.
# Ask docker what is actually BOUND on the machine. `docker compose ps` lists
# exposed ports too, with PublishedPort 0 — grepping its output for "5000" says
# yes even when nothing is published, which it did.
cid=$(docker compose -f "$D/docker-compose.yml" ps -q cmk 2>/dev/null || true)
if [ -n "$cid" ] && [ -n "$(docker port "$cid" 2>/dev/null)" ]; then
  echo "FAIL: the cmk service publishes ports on the machine; the proxy is bypassed:"
  docker port "$cid" | sed "s/^/       /"
  exit 1
fi

echo "OK: desktop, systemd, Checkmk, relative redirects, no bypass, cmk-shell"
