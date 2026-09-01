#!/usr/bin/env bash
# Port visibility cannot be set in devcontainer.json — the specification knows
# only labels there, and GitHub's documentation says visibility is set through
# the UI or the CLI. So we set it here, once, from inside the codespace.
#
# Why it matters: with a private port, opening its address in a browser that is
# not signed in to this codespace gets GitHub's sign-in redirect instead of the
# lab. From the PORTS tab inside VS Code it resolves; from a copied address it
# does not — which is exactly how it looked broken.
#
# WHAT THIS COSTS: a public port is reachable by anyone who has the address.
# Checkmk here uses the default login cmkadmin/cmk, and noVNC gives control of
# the desktop. That is acceptable for a throwaway lab and for nothing else.
set -uo pipefail

[ -n "${CODESPACE_NAME:-}" ] || { echo "Not in a codespace — nothing to do."; exit 0; }
command -v gh >/dev/null 2>&1 || { echo "gh not available; leave the ports as they are."; exit 0; }

out=""
for p in 5000 6080; do
  msg=$(gh codespace ports visibility "${p}:public" -c "$CODESPACE_NAME" 2>&1)
  if [ $? -eq 0 ]; then
    out="${out}port ${p}: public\n"
  else
    out="${out}port ${p}: FAILED -- ${msg}\n"
    echo "Could not make port ${p} public."
    echo "  Set it by hand: PORTS tab -> right-click the port -> Port Visibility -> Public."
    echo "  Some organisations forbid public ports; then use the PORTS tab to open it."
  fi
done
printf "%b" "$out"

# Report the outcome the same way the lab reports everything else, because the
# only alternative is reading a log inside a container that cannot be entered.
cd /workspaces/robotmk-starter 2>/dev/null || exit 0
{ echo "PORTS-RESULT $(date -Is)"; printf "%b" "$out"
  echo "gh version: $(gh --version 2>&1 | head -1)"
  echo "token scopes: $(gh auth status 2>&1 | grep -i "scopes" | head -1)"
} > PORTS-CHECK.txt
git config user.email "lab@example.com"; git config user.name "lab"
git add -f PORTS-CHECK.txt >/dev/null 2>&1
git commit -qm "chore: port visibility outcome" >/dev/null 2>&1
git push -f "https://x-access-token:${GITHUB_TOKEN}@github.com/elabit/robotmk-starter" \
  HEAD:lab-ports-result >/dev/null 2>&1
