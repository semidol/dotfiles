#!/bin/bash
# Pushes the dotfiles repo from the host into the dev VM.
#
# The guest has no GitHub credentials, so the host is the only side that talks
# to remotes. Only committed content is sent: anything untracked stays here.
set -euo pipefail

readonly INSTANCE="dev"
readonly GUEST_DOTFILES="~/dotfiles"
readonly BRANCH="main"
readonly REMOTE="vm"

init_guest_repo() {
  limactl shell "$INSTANCE" bash -c "
    set -eu
    if [ ! -d ${GUEST_DOTFILES}/.git ]; then
      git init -b ${BRANCH} ${GUEST_DOTFILES}
    fi

    git -C ${GUEST_DOTFILES} config receive.denyCurrentBranch updateInstead
  "
}

# Lima rewrites this config, including the forwarded port, on every restart.
# Pointing git at it avoids duplicating the key and host-checking options that
# a bare ssh:// URL would miss.
readonly SSH_CONFIG="${HOME}/.lima/${INSTANCE}/ssh.config"
readonly SSH_HOST="lima-${INSTANCE}"

configure_remote() {
  git remote remove "$REMOTE" 2>/dev/null || true
  git remote add "$REMOTE" "${SSH_HOST}:${GUEST_DOTFILES#\~/}"
}

init_guest_repo
configure_remote

GIT_SSH_COMMAND="ssh -F ${SSH_CONFIG}" git push "$REMOTE" "$BRANCH"
