#!/usr/bin/env bash
# Creates the dev VM and installs the dotfiles into it.
#
# Safe to re-run: an existing instance is reused, and only the missing steps
# are performed.
set -euo pipefail

readonly INSTANCE="${1:-dev}"
readonly DOTFILES="${HOME}/dotfiles"
readonly GUEST_DOTFILES="dotfiles"
readonly TEMPLATE="${DOTFILES}/lima/dev.yaml"
readonly REMOTE="${INSTANCE}-vm"

instance_status() {
  limactl list "$INSTANCE" --format '{{.Status}}' 2>/dev/null
}

create_instance() {
  if [[ -z "$(instance_status)" ]]; then
    limactl create --tty=false --name="$INSTANCE" "$TEMPLATE"
  fi
}

start_instance() {
  if [[ "$(instance_status)" != "Running" ]]; then
    limactl start "$INSTANCE"
  fi
}

push_dotfiles() {
  local branch
  branch="$(git -C "$DOTFILES" branch --show-current)"

  if ! git -C "$DOTFILES" remote get-url "$REMOTE" >/dev/null 2>&1; then
    (cd "$DOTFILES" && "${DOTFILES}/bin/vm-remote" add --vm "$INSTANCE" --path "$GUEST_DOTFILES")
  fi

  git -C "$DOTFILES" push "$REMOTE" "$branch"
}

bootstrap_dotfiles() {
  limactl shell "$INSTANCE" bash -c "~/${GUEST_DOTFILES}/lima/bootstrap-dotfiles.sh"
}

create_instance
start_instance
push_dotfiles
bootstrap_dotfiles
