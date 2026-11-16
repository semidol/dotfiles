# dotfiles

Configs for a macOS host and an isolated Ubuntu dev VM (Lima) for running
coding agents.

## Layout

| Directory | What | Where it goes | Machine |
| --- | --- | --- | --- |
| `aerospace/` | Tiling window manager | `~/.aerospace.toml` | host |
| `wezterm/` | Terminal | `~/.wezterm.lua` | host |
| `hammerspoon/` | floating web apps | `~/.config/hammerspoon2` (v2), `~/.hammerspoon` (v1) | host |
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
ln -sfn ~/dotfiles/hammerspoon ~/.config/hammerspoon2
ln -sfn ~/dotfiles/bin ~/bin
```

Hammerspoon: `init.js` is the Hammerspoon 2 config, `init.lua` the old
Hammerspoon 1 one; run only one of them, they bind the same hotkey. Hammerspoon
2 asks for its config directory on first launch — point it at
`~/dotfiles/hammerspoon` (or symlink it there as above; `hs.appinfo.configDir`
shows the path it actually uses). Its embedded web view needs macOS 26+.

Both versions bind Cmd+Alt+Ctrl+I to a floating ChatGPT pane pinned to the left
third of the screen. The v1 pane looks like a utility window; the v2 one is a
normal titled window whose toolbar carries back/forward/reload and the URL bar.
The URL bar wants a full address, with the scheme.
