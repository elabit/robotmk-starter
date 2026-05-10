#!/usr/bin/env bash
# sync-examples.sh — Pushes each examples/<name>/ as a snapshot to robotmk/example-<name>
#                    and each labs/<name>/ as a snapshot to robotmk/<name>.
#
# Requires:
#   - GH_TOKEN env var with a PAT that has Contents+Administration write on the robotmk org
#   - gh CLI (available on GitHub Actions runners)
#   - git configured with user.name and user.email
#
# Usage:
#   .github/scripts/sync-examples.sh [<example-name>] [--lab <lab-name>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
LABS_DIR="${REPO_ROOT}/labs"
ORG="robotmk"
EXAMPLE_FILTER="${1:-}"
LAB_FILTER="${2:-}"  # passed as second arg from workflow (--lab value handled by caller)
SOURCE_SHA="${GITHUB_SHA:-$(git -C "${REPO_ROOT}" rev-parse HEAD)}"
SOURCE_REPO="${GITHUB_REPOSITORY:-elabit/robotmk-starter}"

# Files/dirs to exclude from sub-repos (relative to examples/<name>/)
EXCLUDE=(
  ".copier-answers.yml"
  "output"
  "log.html"
  "report.html"
  "output.xml"
  "browser"
  "playwright-log.txt"
)

# ─── Helper ──────────────────────────────────────────────────────────────────

ensure_repo() {
  local repo="$1"
  local description="$2"
  if gh repo view "${repo}" &>/dev/null; then
    echo "  ✓ Repo ${repo} already exists"
  else
    echo "  → Creating ${repo} ..."
    gh repo create "${repo}" --public --description "${description}"
  fi
}

build_codespaces_badge() {
  local repo_id="$1"
  local has_devcontainer="$2"   # "true" or "false"
  if [[ "${has_devcontainer}" == "true" ]]; then
    printf '[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=%s)\n' "${repo_id}"
  fi
}

build_header() {
  local name="$1"
  local repo_id="$2"
  local has_devcontainer="$3"
  local badge
  # no button at the beginning
  #badge="$(build_codespaces_badge "${repo_id}" "${has_devcontainer}")"
  [[ -n "${badge}" ]] && printf '%s\n\n' "${badge}"

# <picture>
#   <source media="(prefers-color-scheme: dark)" srcset="https://www.robotmk.org/rmk_crop_transp_w150.png">
#   <source media="(prefers-color-scheme: light)" srcset="https://www.robotmk.org/rmk_crop_transp_150.png">
# </picture>
}

build_footer() {


  cat <<EOF
> ---
>
> **This repository is automatically synced from [${SOURCE_REPO}](https://github.com/${SOURCE_REPO}/tree/main/examples/${name}).**
> Do not edit files here directly — changes will be overwritten on the next sync.
> Last sync: [\`${SOURCE_SHA:0:7}\`](https://github.com/${SOURCE_REPO}/commit/${SOURCE_SHA})

---

EOF

}

build_lab_footer() {
  local name="$1"
  cat <<EOF
> ---
>
> **This repository is automatically synced from [${SOURCE_REPO}](https://github.com/${SOURCE_REPO}/tree/main/labs/${name}).**
> Do not edit files here directly — changes will be overwritten on the next sync.
> Last sync: [\`${SOURCE_SHA:0:7}\`](https://github.com/${SOURCE_REPO}/commit/${SOURCE_SHA})

---

EOF
}

prepare_workdir() {
  local repo="$1"
  local tmpdir="$2"
  local remote_url="https://x-access-token:${GH_TOKEN}@github.com/${repo}.git"

  git init "${tmpdir}" --quiet
  git -C "${tmpdir}" remote add origin "${remote_url}"

  # Try to fetch existing content; silently skip if the repo is brand new (empty)
  if git -C "${tmpdir}" fetch origin main --depth=1 --quiet 2>/dev/null; then
    git -C "${tmpdir}" checkout -b main origin/main --quiet
  else
    git -C "${tmpdir}" checkout -b main --quiet 2>/dev/null || true
  fi
}

prepend_header() {
  local readme="$1"
  local header="$2"
  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "${header}" > "${tmp}"
  cat "${readme}" >> "${tmp}"
  mv "${tmp}" "${readme}"
}

append_footer() {
  local readme="$1"
  local footer="$2"
  if [[ -n "${footer}" ]]; then
    printf '%s\n' "${footer}" >> "${readme}"
  fi
}

sync_example() {
  local name="$1"
  local src="${EXAMPLES_DIR}/${name}"
  local repo="${ORG}/example-${name}"
  local tmpdir
  tmpdir="$(mktemp -d)"

  echo ""
  echo "══ Syncing ${name} → ${repo} ══"

  ensure_repo "${repo}" "Robot Framework example (synced from ${SOURCE_REPO})"

  # Fetch the GitHub repo ID (needed for the Codespaces badge URL)
  local repo_id
  repo_id="$(gh api "repos/${repo}" --jq '.id')"
  echo "  ✓ Repo ID: ${repo_id}"

  # Check whether this example ships a devcontainer
  local has_devcontainer="false"
  [[ -d "${src}/.devcontainer" ]] && has_devcontainer="true"

  # Prepare workdir: fetch existing content or init empty for brand-new repos
  prepare_workdir "${repo}" "${tmpdir}"

  # Wipe tracked content so we do a clean snapshot
  if git -C "${tmpdir}" rev-parse HEAD &>/dev/null; then
    git -C "${tmpdir}" rm -rf . --quiet
  fi

  rsync -a "${src}/" "${tmpdir}/"

  # Remove excluded files/dirs
  for item in "${EXCLUDE[@]}"; do
    rm -rf "${tmpdir:?}/${item}"
  done

  # Prepend sync header and append footer (Codespaces badge) to README if present
  if [[ -f "${tmpdir}/README.md" ]]; then
    prepend_header "${tmpdir}/README.md" "$(build_header "${name}" "${repo_id}" "${has_devcontainer}")"
    append_footer  "${tmpdir}/README.md" "$(build_footer "${repo_id}" "${has_devcontainer}")"
  else
    echo "  ❌ No README.md found — skipping header/footer injection."
  fi

  # Commit and push if anything changed
  git -C "${tmpdir}" add -A
  if git -C "${tmpdir}" diff --cached --quiet; then
    echo "  No changes — skipping push."
  else
    git -C "${tmpdir}" commit -m "sync: from ${SOURCE_REPO}@${SOURCE_SHA:0:7}"
    git -C "${tmpdir}" push -u origin main
    echo "  ✓ Pushed."
  fi

  rm -rf "${tmpdir}"
}

sync_lab() {
  local name="$1"
  local src="${LABS_DIR}/${name}"
  local repo="${ORG}/${name}"
  local tmpdir
  tmpdir="$(mktemp -d)"

  echo ""
  echo "══ Syncing lab ${name} → ${repo} ══"

  ensure_repo "${repo}" "Robotmk Checkmk practice lab (synced from ${SOURCE_REPO})"

  local repo_id
  repo_id="$(gh api "repos/${repo}" --jq '.id')"
  echo "  ✓ Repo ID: ${repo_id}"

  local has_devcontainer="false"
  [[ -d "${src}/.devcontainer" ]] && has_devcontainer="true"

  # Prepare workdir: fetch existing content or init empty for brand-new repos
  prepare_workdir "${repo}" "${tmpdir}"

  # Wipe tracked content so we do a clean snapshot
  if git -C "${tmpdir}" rev-parse HEAD &>/dev/null; then
    git -C "${tmpdir}" rm -rf . --quiet
  fi

  rsync -a "${src}/" "${tmpdir}/"

  for item in "${EXCLUDE[@]}"; do
    rm -rf "${tmpdir:?}/${item}"
  done

  if [[ -f "${tmpdir}/README.md" ]]; then
    prepend_header "${tmpdir}/README.md" "$(build_header "${name}" "${repo_id}" "${has_devcontainer}")"
    append_footer  "${tmpdir}/README.md" "$(build_lab_footer "${name}")"
  else
    echo "  ❌ No README.md found — skipping header/footer injection."
  fi

  git -C "${tmpdir}" add -A
  if git -C "${tmpdir}" diff --cached --quiet; then
    echo "  No changes — skipping push."
  else
    git -C "${tmpdir}" commit -m "sync: from ${SOURCE_REPO}@${SOURCE_SHA:0:7}"
    git -C "${tmpdir}" push -u origin main
    echo "  ✓ Pushed."
  fi

  rm -rf "${tmpdir}"
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo "=== Syncing examples/ ==="
for dir in "${EXAMPLES_DIR}"/*/; do
  name="$(basename "${dir}")"
  if [[ -z "${EXAMPLE_FILTER}" || "${name}" == "${EXAMPLE_FILTER}" ]]; then
    sync_example "${name}"
  fi
done

echo ""
echo "=== Syncing labs/ ==="
if [[ -d "${LABS_DIR}" ]]; then
  for dir in "${LABS_DIR}"/*/; do
    name="$(basename "${dir}")"
    if [[ -z "${LAB_FILTER}" || "${name}" == "${LAB_FILTER}" ]]; then
      sync_lab "${name}"
    fi
  done
fi

echo ""
echo "Sync complete."
