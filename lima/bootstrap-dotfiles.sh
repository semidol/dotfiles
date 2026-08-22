#!/bin/bash
# Links dotfiles into place and installs shell/editor plugins.
#
# Run once, manually, after the SSH key printed by provision-user.sh has been
# registered on GitHub and the dotfiles repo has been cloned to ~/dotfiles.
# Safe to re-run after changing dotfiles.
set -euo pipefail

readonly DOTFILES="${HOME}/dotfiles"
readonly CONFIG="${HOME}/.config"
readonly OH_MY_ZSH="${HOME}/.oh-my-zsh"
readonly ZSH_CUSTOM="${OH_MY_ZSH}/custom"
readonly TPM="${HOME}/.tmux/plugins/tpm"

require_dotfiles() {
  if [[ ! -d "$DOTFILES" ]]; then
    echo >&2 "expected dotfiles at ${DOTFILES}"
    exit 1
  fi
}

link_configs() {
  mkdir -p "$CONFIG"

  ln -sfn "${DOTFILES}/nvim" "${CONFIG}/nvim"
  ln -sfn "${DOTFILES}/tmux" "${CONFIG}/tmux"
  ln -sf "${DOTFILES}/zsh/.zshrc" "${HOME}/.zshrc"
  ln -sfn "${DOTFILES}/bin" "${HOME}/bin"
}

install_oh_my_zsh() {
  if [[ ! -d "$OH_MY_ZSH" ]]; then
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  clone_if_missing() {
    local repo="$1" dest="$2"

    if [[ ! -d "$dest" ]]; then
      git clone --depth=1 "$repo" "$dest"
    fi
  }

  clone_if_missing https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM}/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
    "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
}

install_tmux_plugins() {
  if [[ ! -d "$TPM" ]]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
  fi

  "${TPM}/bin/install_plugins"
}

install_nvim_plugins() {
  nvim --headless "+Lazy! sync" +qa
}

require_dotfiles
link_configs
install_oh_my_zsh
install_tmux_plugins
install_nvim_plugins

echo "dotfiles bootstrapped"
