#!/usr/bin/env bash
# .devcontainer/setup.sh — Runs once after the container is created.
# Downloads RCC, builds the holotree environment, and configures VS Code.

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

step()  { echo -e "\n${CYAN}${BOLD}▶ $*${RESET}"; }
ok()    { echo -e "${GREEN}✓ $*${RESET}"; }
info()  { echo -e "  ${YELLOW}$*${RESET}"; }

RCC_URL="https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_linux64"
RCC_BIN="$HOME/bin/rcc"

# ── Step 1: Download RCC ──────────────────────────────────────────────────────
step "Downloading RCC ..."
mkdir -p "$HOME/bin"
curl -fsSL -o "$RCC_BIN" "$RCC_URL"
chmod +x "$RCC_BIN"
ok "RCC $(${RCC_BIN} --version 2>&1 | head -1) ready at ${RCC_BIN}"

# ── Step 2: Build holotree environment ────────────────────────────────────────
step "Building RCC holotree environment (this takes a few minutes on first run) ..."
info "Reading robot.yaml: $(pwd)/robot.yaml"
SPACE_ROOT=$(
  "$RCC_BIN" holotree vars --robot robot.yaml 2>&1 \
    | grep '^export RCC_HOLOTREE_SPACE_ROOT=' \
    | cut -d= -f2
)
ok "Environment ready at ${SPACE_ROOT}"

# ── Step 3: Symlink ~/.rcc-env ────────────────────────────────────────────────
step "Creating symlink ~/.rcc-env → ${SPACE_ROOT} ..."
ln -sfn "${SPACE_ROOT}" "$HOME/.rcc-env"
ok "~/.rcc-env → ${SPACE_ROOT}"

# ── Step 4: Add to PATH in ~/.bashrc ─────────────────────────────────────────
step "Configuring PATH in ~/.bashrc ..."
MARKER="# rcc-holotree-path"
if grep -q "${MARKER}" "$HOME/.bashrc" 2>/dev/null; then
  info "PATH entry already present — skipping."
else
  echo "${MARKER}" >> "$HOME/.bashrc"
  echo "export PATH=${SPACE_ROOT}/bin:\$PATH" >> "$HOME/.bashrc"
  ok "Added ${SPACE_ROOT}/bin to PATH"
fi

# ── Step 5: Write .vscode/settings.json ──────────────────────────────────────
step "Writing .vscode/settings.json ..."
mkdir -p .vscode
printf '{\n  "python.defaultInterpreterPath": "%s/bin/python"\n}\n' \
  "${SPACE_ROOT}" > .vscode/settings.json
ok "python.defaultInterpreterPath → ${SPACE_ROOT}/bin/python"

echo ""
echo -e "${GREEN}${BOLD}Setup complete.${RESET} Open a new terminal to activate the PATH."
