#!/usr/bin/env bash
# .devcontainer/postcreate.sh — Runs once, only if oncreate.sh (onCreateCommand)
# exited 0 -- the Dev Container lifecycle skips postCreateCommand entirely on
# an onCreateCommand failure, so this script never needs to check whether
# provisioning succeeded (AD-5's halt-on-failure sequencing is enforced by
# the lifecycle itself, not re-checked here).
# Runs RCC + the templates/web-browserlibrary suite and appends the result to
# report.md (already rendered by oncreate.sh's Ansible run).

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

REPORT_FILE="$(pwd)/report.md"

step()  { echo -e "\n${CYAN}${BOLD}▶ $*${RESET}"; }
ok()    { echo -e "${GREEN}✓ $*${RESET}"; }
info()  { echo -e "  ${YELLOW}$*${RESET}"; }
# Unlike oncreate.sh's fail() (which just exits -- report.md doesn't exist yet
# at that point, or gets its own explicit halt-branch write), this fail() must
# itself append the Verification section before exiting: report.md already
# exists by the time postcreate.sh runs, and if a pre-RF-run step (RCC
# download, holotree build) fails, execution never reaches Step 4's append --
# without this, that failure would leave report.md with NO Verification
# section at all, silently worse than "not-run".
fail() {
  echo -e "${RED}${BOLD}✗ $*${RESET}" >&2
  cat >> "${REPORT_FILE}" << EOF

## Verification (Robot Framework)

- **Suite:** templates/web-browserlibrary
- **Result:** fail
- **Reason:** $*
EOF
  exit 1
}

# ── Step 1: Download RCC ─────────────────────────────────────────────────────────
# Unlike the generic devcontainer base image other content types use, the
# stock ubuntu:24.04 image has no curl preinstalled -- install it first.
step "Downloading RCC ..."
if ! command -v curl > /dev/null; then
  apt-get install -y curl || fail "apt-get install curl failed -- cannot download RCC."
fi
RCC_URL="https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_linux64"
RCC_BIN="$HOME/bin/rcc"
mkdir -p "$HOME/bin"
curl -fsSL -o "$RCC_BIN" "$RCC_URL" || fail "Downloading RCC from ${RCC_URL} failed."
chmod +x "$RCC_BIN"
ok "RCC $(${RCC_BIN} --version 2>&1 | head -1) ready at ${RCC_BIN}"

# ── Step 2: Load the verification suite's .env and build its holotree env ──────
# templates/web-browserlibrary is copied in at generation time (populate.yaml),
# not referenced via a parent-repo mount -- this instance is self-contained.
# Loading its .env provides RMKS_ENVIRONMENT (the RCC holotree space name)
# and, critically, ROBOTMK_HEADLESS_HOST=true — this container has no display,
# and Resources/BrowserCommon.resource's Browser Init keyword defaults to
# headed if the var isn't set.
SUITE_DIR="$(pwd)/templates/web-browserlibrary"
[[ -f "${SUITE_DIR}/.env" ]] || fail "${SUITE_DIR}/.env not found -- cannot determine RMKS_ENVIRONMENT."
set -a
# shellcheck disable=SC1091
source "${SUITE_DIR}/.env"
set +a

step "Building RCC holotree environment (space: ${RMKS_ENVIRONMENT}) ..."
"$RCC_BIN" holotree vars --space "${RMKS_ENVIRONMENT}" --robot "${SUITE_DIR}/robot.yaml" > /dev/null \
  || fail "Building the RCC holotree environment failed."
ok "Environment ready for space ${RMKS_ENVIRONMENT}"

# ── Step 3: Run the verification suite ──────────────────────────────────────────
step "Running templates/web-browserlibrary ..."
RF_EXIT=0
(cd "${SUITE_DIR}" && "$RCC_BIN" task script --space "${RMKS_ENVIRONMENT}" --robot robot.yaml -- robot .) || RF_EXIT=$?

if [[ ${RF_EXIT} -eq 0 ]]; then
  RF_RESULT="pass"
  ok "RF suite passed."
else
  RF_RESULT="fail"
  info "RF suite failed (exit ${RF_EXIT})."
fi

# ── Step 4: Record the RF result in report.md ───────────────────────────────────
step "Updating report.md ..."
cat >> "${REPORT_FILE}" << EOF

## Verification (Robot Framework)

- **Suite:** templates/web-browserlibrary
- **Result:** ${RF_RESULT}
- **Output:** ${SUITE_DIR}/output.xml / ${SUITE_DIR}/log.html
EOF
ok "report.md updated."

echo ""
echo -e "${GREEN}${BOLD}Container creation complete.${RESET}"
exit "${RF_EXIT}"
