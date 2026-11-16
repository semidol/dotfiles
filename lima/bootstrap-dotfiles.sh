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
readonly PI_HOME="${HOME}/.pi/agent"

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
  # Only the file is linked: ~/.config/agenmux also holds per-agent .conf
  # overrides, which stay local.
  mkdir -p "${CONFIG}/agenmux"
  ln -sf "${DOTFILES}/agenmux/config.toml" "${CONFIG}/agenmux/config.toml"
  ln -sf "${DOTFILES}/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
  ln -sfn "${DOTFILES}/bin" "${HOME}/bin"
}

# ~/.zshrc stays a real file owned by Lima, which appends a PATH block to
# .profile, .bashrc and .zshrc on every boot unless its marker is already
# there. Symlinking it into the repo would land that block in tracked files,
# so the repo config is sourced from Lima's file instead.
link_zshrc() {
  local source_line="source ${DOTFILES}/zsh/.zshrc"

  if ! grep -qxF "$source_line" "${HOME}/.zshrc" 2>/dev/null; then
    echo "$source_line" >>"${HOME}/.zshrc"
  fi
}

link_pi_config() {
  mkdir -p "${PI_HOME}"

  # Pi rewrites settings.json as it runs, so keep its writable copy outside
  # the repo. Themes are static resources and can be symlinked directly.
  rm -rf "${PI_HOME}/settings.json"
  cp "${DOTFILES}/pi/settings.json" "${PI_HOME}/settings.json"
  rm -rf "${PI_HOME}/themes"
  ln -sfn "${DOTFILES}/pi/themes" "${PI_HOME}/themes"
  rm -rf "${PI_HOME}/skills"
  ln -sfn "${DOTFILES}/pi/skills" "${PI_HOME}/skills"

  if command -v pi >/dev/null 2>&1; then
    pi update --extensions
  fi
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
link_zshrc
link_pi_config
install_oh_my_zsh
install_tmux_plugins
install_nvim_plugins

echo "dotfiles bootstrapped"
