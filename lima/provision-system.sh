#!/bin/bash
# Installs the system-wide toolchain.
# Runs as root on every VM start, so every step must be idempotent.
set -euo pipefail

readonly STAMP="/var/lib/lima-provision-system.done"
readonly NEOVIM_VERSION="v0.12.2"
readonly NEOVIM_ARCH="arm64"
readonly NEOVIM_PREFIX="/opt/nvim-linux-${NEOVIM_ARCH}"

export DEBIAN_FRONTEND=noninteractive

install_base_packages() {
  apt-get update
  apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    file \
    git \
    gnupg \
    jq \
    ripgrep \
    tmux \
    unzip \
    zsh

  # Debian and Ubuntu package fd under a different binary name.
  ln -sf "$(command -v fdfind)" /usr/local/bin/fd
}

install_docker() {
  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  local codename
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable" \
    >/etc/apt/sources.list.d/docker.list

  apt-get update
  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

install_neovim() {
  local url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-${NEOVIM_ARCH}.tar.gz"

  curl -fsSL "$url" -o /tmp/nvim.tar.gz
  tar -xzf /tmp/nvim.tar.gz -C /opt
  rm /tmp/nvim.tar.gz

  ln -sf "${NEOVIM_PREFIX}/bin/nvim" /usr/local/bin/nvim
}

configure_user() {
  usermod -aG docker "$USER_NAME"
  chsh -s "$(command -v zsh)" "$USER_NAME"
}

readonly USER_NAME="$(id -nu 1000)"

if [[ -f "$STAMP" ]]; then
  exit 0
fi

install_base_packages
install_docker
install_neovim
configure_user

touch "$STAMP"
