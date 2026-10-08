#!/bin/bash
# Installs user-level tooling. Runs as the lima user during cloud-init.
#
# The guest never talks to GitHub, so no credentials are configured here.
# Getting dotfiles into the VM is a separate, host-driven step.
set -euo pipefail

readonly STAMP="${HOME}/.local/state/lima-provision-user.done"
readonly FNM_BIN_DIR="${HOME}/.local/share/fnm"
readonly FOUNDRY_BIN_DIR="${HOME}/.foundry/bin"
readonly NODE_VERSION="22"

install_node() {
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

  export PATH="${FNM_BIN_DIR}:${PATH}"
  eval "$(fnm env --shell bash)"

  fnm install "$NODE_VERSION"
  fnm default "$NODE_VERSION"

  corepack enable

  npm install -g @anthropic-ai/claude-code
}

install_foundry() {
  curl -fsSL https://foundry.paradigm.xyz | bash

  "${FOUNDRY_BIN_DIR}/foundryup"
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
}

install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
}

if [[ -f "$STAMP" ]]; then
  exit 0
fi

install_node
install_foundry
install_rust
install_uv

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"
