#!/usr/bin/env bash
# .devcontainer/postcreate.sh — Runs once, only if oncreate.sh (onCreateCommand)
# exited 0 -- the Dev Container lifecycle skips postCreateCommand entirely on
# an onCreateCommand failure, so this script never needs to check whether
# provisioning succeeded (AD-5's halt-on-failure sequencing is enforced by
# the lifecycle itself, not re-checked here).
# Runs RCC + every Robot Framework suite under tests/ and appends each
# result to report.md (already rendered by oncreate.sh's Ansible run).
#
# Shared across every os/ target (rendered from _dev/_os_common) -- the only
# per-family difference is the package manager used to install curl if it's
# missing (Step 1 below).

set -euo pipefail
shopt -s nullglob  # so an empty/missing tests/ iterates zero times, not the literal glob

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
# exists by the time postcreate.sh runs, and if a pre-loop step (RCC
# download) fails, execution never reaches the per-suite loop's own report
# append -- without this, that failure would leave report.md with NO
# Verification section at all, silently worse than "not-run". Only used for
# failures that prevent the suite loop from running at all (Step 1) -- a
# single suite failing inside the loop is recorded per-suite instead (Step 2),
# not treated as fatal to the other suites.
fail() {
  echo -e "${RED}${BOLD}✗ $*${RESET}" >&2
  cat >> "${REPORT_FILE}" << EOF

## Verification (Robot Framework)

- **Suites:** all suites under tests/
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

# ── Step 2: Build the RCC env and run every suite under tests/ ─────────────────
# tests/ is copied in at generation time (populate.yaml), not referenced via
# a parent-repo mount -- this instance is self-contained, and can hold any
# number of suite directories side by side (each self-contained with its own
# robot.yaml/conda.yaml/.env, same shape as an examples/templates instance).
# Every suite is attempted regardless of an earlier one's outcome -- one
# broken suite shouldn't hide whether the others still work -- and the
# overall exit code reflects whether ANY suite failed.
TESTS_DIR="$(pwd)/tests"
SUITE_DIRS=("${TESTS_DIR}"/*/)
[[ -d "${TESTS_DIR}" && -n "${SUITE_DIRS[0]:-}" ]] || fail "No suites found under tests/ -- nothing to verify."

OVERALL_EXIT=0
REPORT_ROWS=()

for suite_path in "${SUITE_DIRS[@]}"; do
  suite_dir="${suite_path%/}"
  suite_name="$(basename "${suite_dir}")"

  step "Verifying tests/${suite_name} ..."

  if [[ ! -f "${suite_dir}/.env" ]]; then
    info "tests/${suite_name}/.env not found -- cannot determine RMKS_ENVIRONMENT, skipping."
    REPORT_ROWS+=("tests/${suite_name}|not-run|.env not found -- cannot determine RMKS_ENVIRONMENT")
    OVERALL_EXIT=1
    continue
  fi

  # Loading each suite's .env provides RMKS_ENVIRONMENT (the RCC holotree
  # space name) and, critically, ROBOTMK_HEADLESS_HOST=true — this container
  # has no display, and Resources/BrowserCommon.resource's Browser Init
  # keyword defaults to headed if the var isn't set. Sourced fresh per
  # iteration (set -a/+a) so it always reflects the current suite, not a
  # previous one's leftover values.
  set -a
  # shellcheck disable=SC1091
  source "${suite_dir}/.env"
  set +a

  step "Building RCC holotree environment (space: ${RMKS_ENVIRONMENT}) ..."
  if ! "$RCC_BIN" holotree vars --space "${RMKS_ENVIRONMENT}" --robot "${suite_dir}/robot.yaml" > /dev/null; then
    info "Building the RCC holotree environment failed for tests/${suite_name}."
    REPORT_ROWS+=("tests/${suite_name}|fail|RCC holotree build failed")
    OVERALL_EXIT=1
    continue
  fi
  ok "Environment ready for space ${RMKS_ENVIRONMENT}"

  step "Running tests/${suite_name} ..."
  RF_EXIT=0
  (cd "${suite_dir}" && "$RCC_BIN" task script --space "${RMKS_ENVIRONMENT}" --robot robot.yaml -- robot .) || RF_EXIT=$?

  if [[ ${RF_EXIT} -eq 0 ]]; then
    ok "tests/${suite_name} passed."
    REPORT_ROWS+=("tests/${suite_name}|pass|${suite_dir}/output.xml / ${suite_dir}/log.html")
  else
    info "tests/${suite_name} failed (exit ${RF_EXIT})."
    REPORT_ROWS+=("tests/${suite_name}|fail|${suite_dir}/output.xml / ${suite_dir}/log.html")
    OVERALL_EXIT=1
  fi
done

# ── Step 3: Record every suite's result in report.md ────────────────────────────
step "Updating report.md ..."
{
  echo ""
  echo "## Verification (Robot Framework)"
  for row in "${REPORT_ROWS[@]}"; do
    IFS='|' read -r suite result detail <<< "${row}"
    echo ""
    echo "### ${suite}"
    echo ""
    echo "- **Result:** ${result}"
    if [[ "${result}" == "pass" || "${result}" == "fail" ]]; then
      echo "- **Output:** ${detail}"
    else
      echo "- **Reason:** ${detail}"
    fi
  done
} >> "${REPORT_FILE}"
ok "report.md updated."

echo ""
if [[ ${OVERALL_EXIT} -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}Container creation complete.${RESET}"
else
  echo -e "${RED}${BOLD}Container creation complete, but one or more suites failed.${RESET}"
fi
exit "${OVERALL_EXIT}"
