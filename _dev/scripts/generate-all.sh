#!/usr/bin/env bash
# generate-all.sh — Regenerates examples/ and templates/ from _dev/_examples/ and _dev/_templates/.
#
# Each source directory may contain a .rcc file with SPACE=<env-name>.
# If present, the matching environment from _dev/_environments/<env-name>/ is injected
# (via Copier) into the template/ subfolder before the main generation step.
#
# Usage:
#   task generate
#   task generate EXAMPLE=cryptolibrary   # single name (both examples/ and templates/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXAMPLES_SRC="${REPO_ROOT}/_dev/_examples"
TEMPLATES_SRC="${REPO_ROOT}/_dev/_templates"
ENVIRONMENTS="${REPO_ROOT}/_dev/_environments"
EXAMPLES_OUT="${REPO_ROOT}/examples"
TEMPLATES_OUT="${REPO_ROOT}/templates"

# Prefer the venv copier if present, otherwise fall back to PATH.
COPIER="${REPO_ROOT}/.venv/bin/copier"
if [[ ! -x "${COPIER}" ]]; then
  COPIER="$(command -v copier || true)"
  if [[ -z "${COPIER}" ]]; then
    echo "Error: copier not found. Run: pip install copier" >&2
    exit 1
  fi
fi

# ─── Version pins (read from _dev/config/versions.env) ──────────────────────
VERSIONS_FILE="${REPO_ROOT}/_dev/config/versions.env"
if [[ ! -f "${VERSIONS_FILE}" ]]; then
  echo "Error: versions.env not found at ${VERSIONS_FILE}" >&2
  exit 1
fi
# shellcheck source=../config/versions.env
source "${VERSIONS_FILE}"
# ─────────────────────────────────────────────────────────────────────────────

COMMON_DATA=(
  --data "rf_version=${RF_VERSION}"
  --data "rf_lib_browser_version=${RF_LIB_BROWSER_VERSION}"
  --data "rf_lib_crypto_version=${RF_LIB_CRYPTO_VERSION}"
  --data "python_version=${PYTHON_VERSION}"
  --data "pip_version=${PIP_VERSION}"
  --data "nodejs_version=${NODEJS_VERSION}"
)

# inject_env: reads .rcc from source dir, injects conda.yaml from matching environment
inject_env() {
  local src="$1"   # e.g. _dev/_examples/cryptolibrary
  local rcc_file="${src}/template/.rcc"
  if [[ ! -f "${rcc_file}" ]]; then
    echo "  (no .rcc file found in ${src}/, skipping environment injection)"
    return
  fi
  local space
  space=$(grep '^SPACE=' "${rcc_file}" | cut -d= -f2 | tr -d '[:space:]')
  [[ -z "${space}" ]] && return
  local env_src="${ENVIRONMENTS}/${space}"
  if [[ ! -d "${env_src}" ]]; then
    echo "  Error: environment '${space}' not found in _dev/_environments/" >&2
    exit 1
  fi
  echo "  ↳ Injecting environment '${space}' ..."
  "${COPIER}" copy --overwrite --defaults "${COMMON_DATA[@]}" "${env_src}" "${src}/template"
  # Remove the env answers file — it's not part of the project template
  rm -f "${src}/template/.copier-env-answers.yml"
}

generate() {
  local name="$1"
  local src_base="$2"
  local dst_base="$3"
  local label="$4"

  echo "→ ${label}/${name}"
  echo "  src: ${src_base}/${name}"
  echo "  dst: ${dst_base}/${name}"
  inject_env "${src_base}/${name}"
  "${COPIER}" copy --overwrite --defaults "${COMMON_DATA[@]}" "${src_base}/${name}" "${dst_base}/${name}"
  echo "  ✓ Done"
}

FILTER="${1:-}"   # optional: generate only a single name

echo "=== examples/ (full working examples) ==="
for dir in "${EXAMPLES_SRC}"/*/; do
  name="$(basename "${dir}")"
  if [[ -z "${FILTER}" || "${name}" == "${FILTER}" ]]; then
    generate "${name}" "${EXAMPLES_SRC}" "${EXAMPLES_OUT}" "examples"
  fi
done

echo ""
echo "=== templates/ (minimal skeletons) ==="
for dir in "${TEMPLATES_SRC}"/*/; do
  name="$(basename "${dir}")"
  if [[ -z "${FILTER}" || "${name}" == "${FILTER}" ]]; then
    generate "${name}" "${TEMPLATES_SRC}" "${TEMPLATES_OUT}" "templates"
  fi
done

echo ""
echo "All done."
