#!/usr/bin/env bash
# The lab's compose file must survive being merged with the overlay Codespaces
# lays over it. A clash here does not fail loudly: Codespaces builds a recovery
# container instead, so the environment appears to start but is not the one built.
set -euo pipefail
H="$(cd "$(dirname "$0")" && pwd)"
D="$H/../template/.devcontainer"
if docker compose -f "$D/docker-compose.yml" -f "$H/overlay-codespaces.yml" config >/dev/null 2>"$H/.err"; then
  echo "OK: merges cleanly with the Codespaces overlay"
else
  echo "FAIL: $(cat "$H/.err")"; rm -f "$H/.err"; exit 1
fi
rm -f "$H/.err"
