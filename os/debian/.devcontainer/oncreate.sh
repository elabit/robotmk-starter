#!/usr/bin/env bash
# .devcontainer/oncreate.sh — Runs once when the container is first created.
# Bootstraps Ansible and runs the playbook to provision OS-level packages
# (the Ansible callback plugin renders report.md as part of that run).
# RF verification is a separate step -- see postcreate.sh -- so a failure
# here (onCreateCommand) is visibly distinct from a failure there
# (postCreateCommand): the Dev Container lifecycle only runs postCreateCommand
# if this script exits 0, so postcreate.sh never needs to check whether
# provisioning succeeded.
#
# Shared across every os/ target (rendered from _dev/_os_common) -- the only
# per-family difference is how ansible-core gets bootstrapped (Step 1 below).

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

step()  { echo -e "\n${CYAN}${BOLD}▶ $*${RESET}"; }
ok()    { echo -e "${GREEN}✓ $*${RESET}"; }
info()  { echo -e "  ${YELLOW}$*${RESET}"; }
fail()  { echo -e "${RED}${BOLD}✗ $*${RESET}" >&2; exit 1; }


export DEBIAN_FRONTEND=noninteractive

REPORT_FILE="$(pwd)/report.md"
# Single source of truth for where the report lives, read by the Ansible
# callback plugin too (see AD-4/AD-6) -- avoids the plugin and this script
# independently re-deriving the same path and risking divergence.
export INSTALL_REPORT_PATH="${REPORT_FILE}"

# ── Step 1: Bootstrap Ansible ──────────────────────────────────────────────────
# Plain shell, not a role — Ansible doesn't exist in the container yet (AD-2).

step "Bootstrapping ansible-core via apt ..."
apt-get update -qq || fail "apt-get update failed -- cannot bootstrap ansible-core."
apt-get install -y ansible-core || fail "apt-get install ansible-core failed."

ok "$(ansible-playbook --version | head -1)"

# ── Step 2: Provision via Ansible ──────────────────────────────────────────────
# Halts on the first task failure (default behavior, no ignore_errors — AD-5).
# Exit code captured explicitly, not left to `set -e`, so a failure can still
# be recorded in report.md before this script exits.
step "Running Ansible playbook ..."
export ANSIBLE_CONFIG="$(pwd)/.devcontainer/ansible.cfg"
# Shared role/callback content is copied in at generation time (populate.yaml,
# from _dev/_ansible/) so this instance is fully self-contained -- no
# /workspace/_dev/... path back into the monorepo. Set via env vars (which
# override ansible.cfg) rather than a relative path in ansible.cfg itself, to
# avoid any ambiguity in how Ansible resolves relative config paths.
export ANSIBLE_ROLES_PATH="$(pwd)/.devcontainer/ansible/roles"
export ANSIBLE_CALLBACK_PLUGINS="$(pwd)/.devcontainer/ansible/callback_plugins"
ANSIBLE_EXIT=0
ansible-playbook -i localhost, -c local .devcontainer/playbook.yml || ANSIBLE_EXIT=$?

if [[ ${ANSIBLE_EXIT} -ne 0 ]]; then
  info "Ansible provisioning failed (exit ${ANSIBLE_EXIT}) — skipping RF verification."
  if [[ -f "${REPORT_FILE}" ]]; then
    # The callback plugin got far enough to render a report (at least one
    # task ran before the halt) -- just append the verification outcome.
    cat >> "${REPORT_FILE}" << EOF

## Verification (Robot Framework)

- **Suites:** all suites under tests/
- **Result:** not-run
- **Reason:** provisioning did not complete
EOF
  else
    # ansible-playbook failed before any task ran (e.g. a playbook/role
    # parse error) -- the callback's v2_playbook_on_stats never fired, so
    # no report exists yet. Write a minimal one rather than silently
    # implying a partial run happened.
    cat > "${REPORT_FILE}" << EOF
# OS Install Report

**Generated:** $(date -Iseconds)

Ansible provisioning failed before any task ran (exit ${ANSIBLE_EXIT}) — no per-step detail is available. Check the container build log for the underlying error (e.g. a playbook/role syntax error).

## Verification (Robot Framework)

- **Suites:** all suites under tests/
- **Result:** not-run
- **Reason:** provisioning did not complete
EOF
  fi
  exit "${ANSIBLE_EXIT}"
fi

ok "Provisioning complete."
