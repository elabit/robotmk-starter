#!/usr/bin/env bash
# The container measures itself and pushes the result back into the branch.
#
# Deliberately not over SSH: `gh codespace ssh` depends on the sshd feature's key
# injection, and features that carry "init" take PID 1 away from systemd — the
# very thing this lab needs. So the lab reports, instead of being interrogated.
# The same pattern is the only workable one for CI of this lab.
exec > /var/log/lab-report.log 2>&1
set -x
cd /workspaces/robotmk-starter || exit 0

# Wait before measuring. postCreateCommand runs while the machine is still
# coming up, and a self-check that asks "is everything up?" during boot answers
# its own question wrongly. Checkmk in particular takes minutes: measured, its
# container briefly pulls over 1600 % CPU while the site starts.
for _ in $(seq 1 60); do
  [[ "$(systemctl is-system-running 2>&1)" =~ ^(running|degraded)$ ]] && break
  sleep 5
done
# How long the Checkmk site really needs on the two-core machine this lab
# targets. The course has to tell the learner a number, and a guessed one is
# worse than none: whoever waits less than the truth thinks it hung.
CMK_WAIT_START=$(date +%s)
CMK_SECONDS="over 1200"
for _ in $(seq 1 240); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://cmk:5000/cmk/" 2>/dev/null)
  if [[ "$code" != "000" ]]; then
    CMK_SECONDS=$(( $(date +%s) - CMK_WAIT_START ))
    break
  fi
  sleep 5
done

{
  echo "measured:          $(date -Is)"
  echo "PID 1:             $(cat /proc/1/comm)"
  echo "is-system-running: $(systemctl is-system-running 2>&1)"
  echo "failed units:      $(systemctl --failed --no-legend 2>/dev/null | wc -l | tr -d ' ')"
  echo "vncserver:         $(systemctl is-active vncserver 2>&1)"
  echo "novnc:             $(systemctl is-active novnc 2>&1)"
  echo "cmk resolves:      $(getent hosts cmk 2>/dev/null | awk '{print $1}' || echo NO)"
  echo "cmk port 5000:     $(timeout 3 bash -c '</dev/tcp/cmk/5000' 2>/dev/null && echo open || echo closed)"
  echo "checkmk waited:    ${CMK_SECONDS} s after systemd settled"
  echo "checkmk reachable: $(curl -s -o /dev/null -w '%{http_code}' http://cmk:5000/cmk/ 2>/dev/null)"
  echo "compose peers:     $(getent ahostsv4 cmk 2>/dev/null | head -1 || echo none)"
  echo "ROBOLAND_KEY set:  $(test -n "${ROBOLAND_KEY:-}" && echo yes || echo NO)"
  echo "rcc preinstalled:  $(command -v rcc >/dev/null 2>&1 && echo YES-BAD || echo no)"
  echo "novnc root page:   $(curl -s http://127.0.0.1:6080/ | grep -q vnc.html && echo "leads to viewer" || echo BROKEN)"
  echo "terminal present:  $(command -v xterm >/dev/null 2>&1 && echo yes || echo NO)"
  echo "desktop-session:   $(systemctl is-active desktop-session 2>&1)"
  echo "checkmk on localhost: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:5000/cmk/ 2>/dev/null)"
  echo "cmk-shell reaches site: $(cmk-shell omd version 2>&1 | head -1)"
  echo "redirect for localhost: $(curl -s -o /dev/null -D - -H 'Host: localhost:5000' http://127.0.0.1:5000/cmk/ 2>/dev/null | grep -i '^location' | tr -d '\r')"
} > LAB-CHECK.txt
git config user.email "lab@example.com"
git config user.name  "lab"
git add -f LAB-CHECK.txt
git commit -m "chore: lab self-check from the codespace"
# Push to a branch of its own, never to the one being worked on: two writers on
# one ref means every result races with the next commit.
git push -f "https://x-access-token:${GITHUB_TOKEN}@github.com/elabit/robotmk-starter" \
  HEAD:lab-check-result
