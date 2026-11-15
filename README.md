# dotfiles

Configs for a macOS host and an isolated Ubuntu dev VM (Lima) for running
coding agents.

## Layout

| Directory | What | Where it goes | Machine |
| --- | --- | --- | --- |
| `aerospace/` | Tiling window manager | `~/.aerospace.toml` | host |
| `wezterm/` | Terminal | `~/.wezterm.lua` | host |
| `hammerspoon/` | floating web apps | `~/.hammerspoon` | host |
| `lima/` | Dev VM definition and provisioning | used in place | host |
| `zsh/` | Shell, p10k prompt | sourced from `~/.zshrc`, `~/.p10k.zsh` | VM |
| `tmux/` | tmux config and session helpers | `~/.config/tmux` | VM |
| `nvim/` | Neovim config | `~/.config/nvim` | VM |
| `pi/` | Pi settings, themes and skills | `~/.pi/agent/*` | VM |
| `bin/` | Utilities, each described in its header | `~/bin` | both |

## Setup

VM: `lima/setup-vm.sh` on the host creates the VM and runs
`lima/bootstrap-dotfiles.sh` inside it. See [lima/README.md](lima/README.md).
Pi's settings are copied because Pi updates them at runtime; its themes and
personal skills are symlinked. See [pi/README.md](pi/README.md).

Host: no installer, symlink the host configs by hand:

```sh
ln -sf ~/dotfiles/aerospace/.aerospace.toml ~/.aerospace.toml
ln -sf ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
ln -sfn ~/dotfiles/hammerspoon ~/.hammerspoon
ln -sfn ~/dotfiles/bin ~/bin
```
