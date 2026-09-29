# dotfiles

Configs for a macOS host and an isolated Ubuntu dev VM (Lima) where Claude
runs without permission prompts.

## Layout

| Directory | What | Where it goes | Machine |
| --- | --- | --- | --- |
| `aerospace/` | Tiling window manager | `~/.aerospace.toml` | host |
| `wezterm/` | Terminal | `~/.wezterm.lua` | host |
| `lima/` | Dev VM definition and provisioning | used in place | host |
| `zsh/` | Shell, p10k prompt | sourced from `~/.zshrc`, `~/.p10k.zsh` | VM |
| `tmux/` | tmux config and session helpers | `~/.config/tmux` | VM |
| `nvim/` | Neovim config | `~/.config/nvim` | VM |
| `claude/` | Claude Code config and skills | `~/.claude/*` | VM |
| `bin/` | Utilities, each described in its header | `~/bin` | both |

## Setup

VM: `lima/setup-vm.sh` on the host creates the VM and runs
`lima/bootstrap-dotfiles.sh` inside it. See [lima/README.md](lima/README.md).

Host: no installer, symlink the host configs by hand:

```sh
ln -sf ~/dotfiles/aerospace/.aerospace.toml ~/.aerospace.toml
ln -sf ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
ln -sfn ~/dotfiles/bin ~/bin
```
