#!/usr/bin/env bash
# test-systemd.sh — systemd must be PID 1, and the things the learner is meant
# to install must NOT be baked into the image.
set -euo pipefail
D="$(cd "$(dirname "$0")/../template/.devcontainer" && pwd)"
docker compose -f "$D/docker-compose.yml" up -d --build host
trap 'docker compose -f "$D/docker-compose.yml" down -v' EXIT
ex() { docker compose -f "$D/docker-compose.yml" exec -T host "$@"; }

s=""
for _ in $(seq 1 30); do
  s=$(ex systemctl is-system-running 2>&1 || true)
  [[ "$s" == running || "$s" == degraded ]] && break
  sleep 2
done
[[ "$(ex cat /proc/1/comm)" == systemd* ]] || { echo "FAIL: PID 1 is not systemd"; exit 1; }
[[ "$s" == running ]] || { echo "FAIL: is-system-running = $s"; exit 1; }

# Whatever the learner is supposed to install must not be there already.
for forbidden in rcc cmk-agent-ctl; do
  if ex command -v "$forbidden" >/dev/null 2>&1; then
    echo "FAIL: $forbidden is preinstalled — the learner is meant to do that"; exit 1
  fi
done
echo "OK: systemd runs as PID 1, RCC and agent absent as intended"
