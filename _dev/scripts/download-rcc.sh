#!/usr/bin/env bash
# download-rcc.sh — Downloads the RCC binary for the current OS into _dev/.rcc/.
# RCC binaries are NOT committed to git (see .gitignore).
# Run this once after cloning the repo before running tests locally.
#
# Usage:
#   ./_dev/scripts/download-rcc.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RCC_DIR="${SCRIPT_DIR}/../.rcc"
mkdir -p "${RCC_DIR}"

OS="$(uname -s)"
ARCH="$(uname -m)"

RCC_BASE_URL="https://github.com/elabit/robotmk/releases/download/v4.0.0"

case "${OS}" in
  Linux)
    DEST="${RCC_DIR}/rcc"
    URL="${RCC_BASE_URL}/rcc_linux64"
    ;;
  Darwin)
    DEST="${RCC_DIR}/rcc"
    URL="${RCC_BASE_URL}/rcc_macos64"
    ;;
  *)
    echo "Error: unsupported OS '${OS}'. On Windows, run download-rcc.ps1 instead." >&2
    exit 1
    ;;
esac

echo "→ Downloading RCC for ${OS} (${ARCH}) ..."
curl -fsSL -o "${DEST}" "${URL}"
chmod +x "${DEST}"
echo "  ✓ Saved to: ${DEST}"
"${DEST}" --version
