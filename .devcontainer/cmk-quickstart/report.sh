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
{
  echo "measured:          $(date -Is)"
  echo "PID 1:             $(cat /proc/1/comm)"
  echo "is-system-running: $(systemctl is-system-running 2>&1)"
  echo "failed units:      $(systemctl --failed --no-legend 2>/dev/null | wc -l | tr -d ' ')"
  echo "vncserver:         $(systemctl is-active vncserver 2>&1)"
  echo "novnc:             $(systemctl is-active novnc 2>&1)"
  echo "checkmk reachable: $(curl -s -o /dev/null -w '%{http_code}' http://cmk:5000/cmk/ 2>&1)"
  echo "ROBOLAND_KEY set:  $(test -n "${ROBOLAND_KEY:-}" && echo yes || echo NO)"
  echo "rcc preinstalled:  $(command -v rcc >/dev/null 2>&1 && echo YES-BAD || echo no)"
} > LAB-CHECK.txt
git config user.email "lab@example.com"
git config user.name  "lab"
git add -f LAB-CHECK.txt
git commit -m "chore: lab self-check from the codespace"
git push "https://x-access-token:${GITHUB_TOKEN}@github.com/elabit/robotmk-starter" \
  HEAD:feat/lab-cmk-quickstart
