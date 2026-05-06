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
info "robot.yaml: $(pwd)/robot.yaml"
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
cat > .vscode/settings.json <<EOF
{
  "python.defaultInterpreterPath": "${SPACE_ROOT}/bin/python",
  "python-envs.defaultEnvManager": "ms-python.python:system",
  "robotcode.run.openOutputAfterRun": "log",
  "window.autoDetectColorScheme": true
}
EOF
ok "python.defaultInterpreterPath → ${SPACE_ROOT}/bin/python"

# ── Step 6: Configure fluxbox resolution ─────────────────────────────────────
step "Configuring fluxbox resolution ..."
FLUXBOX_STARTUP="$HOME/.fluxbox/startup"
# Read VNC_RESOLUTION from .env if present, otherwise fall back to default
VNC_RESOLUTION="1280x1024"
if grep -q '^VNC_RESOLUTION=' .env 2>/dev/null; then
  VNC_RESOLUTION="$(grep '^VNC_RESOLUTION=' .env | cut -d= -f2 | tr -d '[:space:]')"
fi
XRANDR_LINE="xrandr --output VNC-0 --mode ${VNC_RESOLUTION}"
if grep -qF "xrandr --output VNC-0 --mode" "${FLUXBOX_STARTUP}" 2>/dev/null; then
  info "xrandr entry already present — skipping."
else
  sed -i "s|^exec fluxbox|${XRANDR_LINE}\nexec fluxbox|" "${FLUXBOX_STARTUP}"
  ok "Set VNC resolution to ${VNC_RESOLUTION} in ${FLUXBOX_STARTUP}"
fi

echo ""
echo -e "${GREEN}${BOLD}Setup complete.${RESET} Open a new terminal to activate the PATH."
