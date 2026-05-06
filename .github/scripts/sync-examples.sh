#!/usr/bin/env bash
# sync-examples.sh — Pushes each examples/<name>/ as a snapshot to robotmk/example-<name>.
#
# Requires:
#   - GH_TOKEN env var with a PAT that has Contents+Administration write on the robotmk org
#   - gh CLI (available on GitHub Actions runners)
#   - git configured with user.name and user.email
#
# Usage:
#   .github/scripts/sync-examples.sh [<name>]   # optional: sync only one example

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
ORG="robotmk"
FILTER="${1:-}"
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
  if gh repo view "${repo}" &>/dev/null; then
    echo "  ✓ Repo ${repo} already exists"
  else
    echo "  → Creating ${repo} ..."
    gh repo create "${repo}" --public --description "Robot Framework example (synced from ${SOURCE_REPO})"
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
  badge="$(build_codespaces_badge "${repo_id}" "${has_devcontainer}")"
  [[ -n "${badge}" ]] && printf '%s\n\n' "${badge}"
  cat <<EOF
> **This repository is automatically synced from [${SOURCE_REPO}](https://github.com/${SOURCE_REPO}/tree/main/examples/${name}).**
> Do not edit files here directly — changes will be overwritten on the next sync.
> Last sync: [\`${SOURCE_SHA:0:7}\`](https://github.com/${SOURCE_REPO}/commit/${SOURCE_SHA})

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://www.robotmk.org/rmk_crop_transp_w150.png">
  <source media="(prefers-color-scheme: light)" srcset="https://www.robotmk.org/rmk_crop_transp_150.png">
</picture>


---

EOF
}

build_footer() {
  local repo_id="$1"
  local has_devcontainer="$2"
  local badge
  badge="$(build_codespaces_badge "${repo_id}" "${has_devcontainer}")"
  if [[ -n "${badge}" ]]; then
    printf '\n%s\n' "${badge}"
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

  ensure_repo "${repo}"

  # Fetch the GitHub repo ID (needed for the Codespaces badge URL)
  local repo_id
  repo_id="$(gh api "repos/${repo}" --jq '.id')"
  echo "  ✓ Repo ID: ${repo_id}"

  # Check whether this example ships a devcontainer
  local has_devcontainer="false"
  [[ -d "${src}/.devcontainer" ]] && has_devcontainer="true"

  # Clone (shallow, only default branch)
  gh repo clone "${repo}" "${tmpdir}" -- --depth=1 --quiet

  # Inject token into remote URL so git push can authenticate
  git -C "${tmpdir}" remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${repo}.git"

  # Wipe tracked content (skip if repo is empty / no commits yet)
  if git -C "${tmpdir}" rev-parse HEAD &>/dev/null; then
    git -C "${tmpdir}" rm -rf . --quiet
  fi

  # Copy example content (rsync excludes handled below)
  rsync -a "${src}/" "${tmpdir}/"

  # Remove excluded files/dirs
  for item in "${EXCLUDE[@]}"; do
    rm -rf "${tmpdir:?}/${item}"
  done

  # Prepend sync header and append footer (Codespaces badge) to README if present
  if [[ -f "${tmpdir}/README.md" ]]; then
    prepend_header "${tmpdir}/README.md" "$(build_header "${name}" "${repo_id}" "${has_devcontainer}")"
    append_footer  "${tmpdir}/README.md" "$(build_footer "${repo_id}" "${has_devcontainer}")"
  fi

  # Commit and push if anything changed
  git -C "${tmpdir}" add -A
  if git -C "${tmpdir}" diff --cached --quiet; then
    echo "  No changes — skipping push."
  else
    git -C "${tmpdir}" commit -m "sync: from ${SOURCE_REPO}@${SOURCE_SHA:0:7}"
    git -C "${tmpdir}" push
    echo "  ✓ Pushed."
  fi

  rm -rf "${tmpdir}"
}

# ─── Main ────────────────────────────────────────────────────────────────────

for dir in "${EXAMPLES_DIR}"/*/; do
  name="$(basename "${dir}")"
  if [[ -z "${FILTER}" || "${name}" == "${FILTER}" ]]; then
    sync_example "${name}"
  fi
done

echo ""
echo "Sync complete."
