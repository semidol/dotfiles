#!/bin/bash
# Installs user-level tooling and generates the git SSH key.
# Runs as the lima user on every VM start, so every step must be idempotent.
#
# Dotfiles are deliberately NOT cloned here: the key generated below has to be
# registered on GitHub first. Run bootstrap-dotfiles.sh once that is done.
set -euo pipefail

readonly STAMP="${HOME}/.local/state/lima-provision-user.done"
readonly SSH_KEY="${HOME}/.ssh/id_personal"
readonly SSH_HOST_ALIAS="github-personal"
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

generate_git_key() {
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  if [[ ! -f "$SSH_KEY" ]]; then
    ssh-keygen -t ed25519 -N "" -f "$SSH_KEY" -C "lima-dev-personal"
  fi

  cat >"${HOME}/.ssh/config" <<EOF
Host ${SSH_HOST_ALIAS}
  HostName github.com
  User git
  IdentityFile ${SSH_KEY}
  IdentitiesOnly yes
EOF

  chmod 600 "${HOME}/.ssh/config"

  if ! grep -q "github.com" "${HOME}/.ssh/known_hosts" 2>/dev/null; then
    ssh-keyscan -t ed25519 github.com >>"${HOME}/.ssh/known_hosts" 2>/dev/null
  fi
}

report_next_steps() {
  # Dotfiles already present means the one-time setup is done.
  if [[ -d "${HOME}/dotfiles" ]]; then
    return
  fi

  echo "=========================================================="
  echo "Register this key at https://github.com/settings/keys"
  echo
  cat "${SSH_KEY}.pub"
  echo
  echo "Then, inside the VM, run:"
  echo "  git clone git@${SSH_HOST_ALIAS}:semidol/dotfiles.git ~/dotfiles"
  echo "  ~/dotfiles/lima/bootstrap-dotfiles.sh"
  echo "=========================================================="
}

if [[ -f "$STAMP" ]]; then
  exit 0
fi

install_node
install_foundry
generate_git_key

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"

report_next_steps
