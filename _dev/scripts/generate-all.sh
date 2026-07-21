#!/usr/bin/env bash
# generate-all.sh — Regenerates examples/, templates/, labs/, and os/ from
# their _dev/_examples/, _dev/_templates/, _dev/_labs/, and _dev/_os/ sources.
#
# Each examples/templates/labs source's template/.env must contain
# RMKS_ENVIRONMENT=<env-name> and RMKS_DEVCONTAINER=<type>. These replace the
# former .rcc and .devcontainer-type files and drive environment and
# devcontainer injection via Copier.
#
# os/ sources do NOT use the .env/RMKS_* convention — each os/<slug>'s
# devcontainer is authored directly in its Copier source (no injection), and
# its base-image tag is looked up from versions.env as <SLUG-UPPER>_IMAGE.
#
# Usage:
#   task generate
#   task generate EXAMPLE=cryptolibrary   # single name (matches across every content type)

set -euo pipefail
shopt -s nullglob  # so an empty source dir (e.g. no os/ instances yet) iterates zero times instead of passing the literal glob through

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

# Prefer the venv python if present, otherwise fall back to PATH.
PYTHON="${REPO_ROOT}/.venv/bin/python3"
if [[ ! -x "${PYTHON}" ]]; then
  PYTHON="$(command -v python3 || command -v python || true)"
  if [[ -z "${PYTHON}" ]]; then
    echo "Error: python3 not found." >&2
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

DEVCONTAINERS="${REPO_ROOT}/_dev/_devcontainers"

# inject_devcontainer: reads VNC from template/.env, injects the
# matching devcontainer config (headless or desktop) into template/.devcontainer/
# inject_devcontainer: reads RMKS_DEVCONTAINER from template/.env and injects
# the matching devcontainer config into template/.devcontainer/.
inject_devcontainer() {
  local src="$1"   # e.g. _dev/_examples/cryptolibrary-simple
  local name
  name="$(basename "${src}")"

  local env_file="${src}/template/.env"
  if [[ ! -f "${env_file}" ]]; then
    echo "  (no .env found in ${src}/template/, skipping devcontainer injection)"
    return
  fi

  local dc_type
  dc_type=$(grep '^RMKS_DEVCONTAINER=' "${env_file}" | cut -d= -f2 | tr -d '[:space:]' || true)
  if [[ -z "${dc_type}" ]]; then
    echo "  (no RMKS_DEVCONTAINER in ${src}/template/.env, skipping devcontainer injection)"
    return
  fi

  local dc_src="${DEVCONTAINERS}/${dc_type}"
  if [[ ! -d "${dc_src}" ]]; then
    echo "  Error: devcontainer type '${dc_type}' not found in _dev/_devcontainers/" >&2
    exit 1
  fi
  echo "  ↳ Injecting devcontainer '${dc_type}' ..."
  "${COPIER}" copy --overwrite --defaults \
    --data "example_name=${name}" \
    "${dc_src}" "${src}/template"
  rm -f "${src}/template/.copier-devcontainer-answers.yml"
}

# inject_env: reads RMKS_ENVIRONMENT from template/.env, injects conda.yaml
# from the matching environment directory.
inject_env() {
  local src="$1"   # e.g. _dev/_examples/cryptolibrary
  local env_file="${src}/template/.env"
  if [[ ! -f "${env_file}" ]]; then
    echo "  (no .env file found in ${src}/template/, skipping environment injection)"
    return
  fi
  local space
  space=$(grep '^RMKS_ENVIRONMENT=' "${env_file}" | cut -d= -f2 | tr -d '[:space:]')
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

SHARED_DIR="${REPO_ROOT}/_dev/_shared"

generate() {
  local name="$1"
  local src_base="$2"
  local dst_base="$3"
  local label="$4"
  shift 4
  local extra_data=("$@")  # optional additional --data args (used by the os/ loop)

  echo "→ ${label}/${name}"
  echo "  src: ${src_base}/${name}"
  echo "  dst: ${dst_base}/${name}"

  # Purge destination to ensure idempotency
  if [[ -d "${dst_base}/${name}" ]]; then
    echo "  ↳ Purging ${dst_base}/${name} ..."
    rm -rf "${dst_base}/${name}"
  fi

  # Inject shared README template if the example has a partial
  local shared_readme="${SHARED_DIR}/README.md.jinja"
  local partial="${src_base}/${name}/README.partial.md"
  if [[ -f "${shared_readme}" && -f "${partial}" ]]; then
    echo "  ↳ Injecting shared README.md.jinja ..."
    cp "${shared_readme}" "${src_base}/${name}/template/README.md.jinja"
  fi

  # Inject shared how-to-run partial (included by README.partial.md after H1)
  local shared_intro="${SHARED_DIR}/how-to-run.partial.md"
  if [[ -f "${shared_intro}" && -f "${partial}" ]]; then
    echo "  ↳ Injecting shared how-to-run.partial.md ..."
    cp "${shared_intro}" "${src_base}/${name}/how-to-run.partial.md"
  fi

  # Inject lab-specific how-to-run partial (for labs using how-to-run-lab.partial.md)
  local shared_lab_intro="${SHARED_DIR}/how-to-run-lab.partial.md"
  if [[ -f "${shared_lab_intro}" ]]; then
    cp "${shared_lab_intro}" "${src_base}/${name}/how-to-run-lab.partial.md"
  fi

  # os/ never uses the .env-driven RMKS_DEVCONTAINER/RMKS_ENVIRONMENT
  # indirection (each os/<slug> devcontainer is authored directly in its
  # Copier source) -- guarded explicitly, not just relying on os/ sources
  # happening to have no template/.env today.
  if [[ "${label}" != "os" ]]; then
    inject_devcontainer "${src_base}/${name}"
    inject_env "${src_base}/${name}"
  fi
  # Move the generated versions partial from template/ to root so Jinja can find it
  # (Copier's include loader searches the source root, not the _subdirectory)
  if [[ -f "${src_base}/${name}/template/versions.partial.md" ]]; then
    mv "${src_base}/${name}/template/versions.partial.md" "${src_base}/${name}/versions.partial.md"
  fi
  "${COPIER}" copy --overwrite --defaults "${COMMON_DATA[@]}" "${extra_data[@]}" \
    --data "example_name=${name}" \
    "${src_base}/${name}" "${dst_base}/${name}"

  # Post-copier populate: copy additional files/dirs defined in populate.yaml
  if [[ -f "${src_base}/${name}/populate.yaml" ]]; then
    echo "  ↳ Running populate.yaml ..."
    "${PYTHON}" "${REPO_ROOT}/_dev/scripts/populate.py" \
      "${src_base}/${name}/populate.yaml" \
      "${REPO_ROOT}" \
      "${dst_base}/${name}"
  fi

  # Remove the injected shared README template from the source tree
  rm -f "${src_base}/${name}/template/README.md.jinja"
  # Remove the versions partial (now at root; not in template/ so never in output)
  rm -f "${src_base}/${name}/versions.partial.md"
  # Remove the injected how-to-run partials from the source tree
  rm -f "${src_base}/${name}/how-to-run.partial.md"
  rm -f "${src_base}/${name}/how-to-run-lab.partial.md"
  # Remove the injected devcontainer files from the source tree — except for
  # the os/ content type, where .devcontainer/ is permanent, hand-authored
  # source content (AD-10), not an injected/temporary artifact like every
  # other content type's devcontainer files.
  if [[ "${label}" != "os" ]]; then
    rm -rf "${src_base}/${name}/template/.devcontainer"
  fi

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
echo "=== labs/ (Checkmk practice labs) ==="
LABS_SRC="${REPO_ROOT}/_dev/_labs"
LABS_OUT="${REPO_ROOT}/labs"
if [[ -d "${LABS_SRC}" ]]; then
  for dir in "${LABS_SRC}"/*/; do
    name="$(basename "${dir}")"
    if [[ -z "${FILTER}" || "${name}" == "${FILTER}" ]]; then
      generate "${name}" "${LABS_SRC}" "${LABS_OUT}" "labs"
    fi
  done
fi

echo ""
echo "=== os/ (Ansible-provisioned OS install verification) ==="
OS_SRC="${REPO_ROOT}/_dev/_os"
OS_OUT="${REPO_ROOT}/os"
if [[ -d "${OS_SRC}" ]]; then
  for dir in "${OS_SRC}"/*/; do
    name="$(basename "${dir}")"
    if [[ -z "${FILTER}" || "${name}" == "${FILTER}" ]]; then
      if [[ ! "${name}" =~ ^[a-z0-9_]+$ ]]; then
        echo "  Error: os/ slug '${name}' must be lowercase letters/digits/underscore only (needed to derive a valid <SLUG>_IMAGE env var name)" >&2
        exit 1
      fi
      # Derive the version-pin key generically from the slug (debian -> DEBIAN_IMAGE)
      # so adding a new OS target never requires editing this script. The
      # rhel slug is the one flagged exception (Story 1.1): its versions.env
      # key is RHEL_COMPAT_IMAGE, not the generically-derived RHEL_IMAGE,
      # because the slug names the target FAMILY while the pin documents that
      # the actual image is a RHEL-compatible substitute (Rocky Linux), not
      # RHEL itself.
      if [[ "${name}" == "rhel" ]]; then
        image_var="RHEL_COMPAT_IMAGE"
      else
        image_var="$(echo "${name}" | tr '[:lower:]' '[:upper:]')_IMAGE"
      fi
      image_value="${!image_var:-}"
      if [[ -z "${image_value}" ]]; then
        echo "  Error: ${image_var} not set in versions.env for os/${name}" >&2
        exit 1
      fi
      generate "${name}" "${OS_SRC}" "${OS_OUT}" "os" --data "${name}_image=${image_value}"
    fi
  done
fi

echo ""
echo "All done."
