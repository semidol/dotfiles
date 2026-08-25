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

    # The host pushes straight into the checked-out branch, so receiving a
    # push has to update the working tree instead of only moving the ref.
    git -C ${GUEST_DOTFILES} config receive.denyCurrentBranch updateInstead
  "
}

# Lima regenerates this config, including the forwarded port, on every restart.
# Reusing it keeps the identity file and host-key options in one place instead
# of duplicating them into a ssh:// URL.
ssh_config_path() {
  limactl list "$INSTANCE" --format '{{.SSHConfigFile}}'
}

ssh_host_alias() {
  awk '/^Host /{print $2; exit}' "$1"
}

configure_remote() {
  local host="$1"

  git remote remove "$REMOTE" 2>/dev/null || true
  git remote add "$REMOTE" "${host}:${GUEST_DOTFILES#\~/}"
}

readonly SSH_CONFIG="$(ssh_config_path)"

init_guest_repo
configure_remote "$(ssh_host_alias "$SSH_CONFIG")"

GIT_SSH_COMMAND="ssh -F ${SSH_CONFIG}" git push "$REMOTE" "$BRANCH"
