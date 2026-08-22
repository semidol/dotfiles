#!/bin/bash
# Installs user-level tooling and configures git credential storage.
# Runs as the lima user during cloud-init.
#
# Dotfiles are deliberately NOT cloned here: cloning needs a GitHub token that
# has to be entered interactively. Run bootstrap-dotfiles.sh once that is done.
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

  npm install -g @anthropic-ai/claude-code
}

install_foundry() {
  curl -fsSL https://foundry.paradigm.xyz | bash

  "${FOUNDRY_BIN_DIR}/foundryup"
}

configure_git_credentials() {
  git config --global credential.helper store

  # Store one credential per repository path rather than per host,
  # so several GitHub accounts can coexist.
  git config --global credential.https://github.com.useHttpPath true
}

if [[ -f "$STAMP" ]]; then
  exit 0
fi

install_node
install_foundry
configure_git_credentials

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"
