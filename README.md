# dotfiles

Configs for a macOS host and an isolated Ubuntu dev VM (Lima) for running
coding agents.

## Layout

| Directory | What | Where it goes | Machine |
| --- | --- | --- | --- |
| `aerospace/` | Tiling window manager | `~/.aerospace.toml` | host |
| `wezterm/` | Terminal | `~/.wezterm.lua` | host |
| `hammerspoon/` | floating web apps | `~/.config/hammerspoon2` | host |
| `keyboard/` | keyboard tooling: Karabiner (hyper on right Command, Control ⇄ fn, Caps Lock → Esc) | `~/.config/karabiner`, `~/dotfiles/keyboard` | host |
| `lima/` | Dev VM definition and provisioning | used in place | host |
| `zsh/` | Shell, p10k prompt | sourced from `~/.zshrc`, `~/.p10k.zsh` | VM |
| `tmux/` | tmux config and session helpers | `~/.config/tmux` | VM |
| `agenmux/` | agenmux sidebar settings | `~/.config/agenmux/config.toml` | VM |
| `nvim/` | Neovim config | `~/.config/nvim` | VM |
| `pi/` | Pi settings, compact-tools config, themes and skills | `~/.pi/agent/*` | VM |
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
ln -sfn ~/dotfiles/bin ~/bin
ln -sfn ~/dotfiles/keyboard/karabiner/complex-modifications.json \
  ~/.config/karabiner/assets/complex_modifications/complex-modifications.json
```

Karabiner's complex modification is enabled once by hand in its UI; see
[keyboard/README.md](keyboard/README.md).

Hammerspoon 2 asks for its config directory on first launch — point it straight
at `~/dotfiles/hammerspoon` (`hs.appinfo.configDir` shows the path it actually
uses), no symlink needed. Its embedded web view needs macOS 26+.

Cmd+Alt+Ctrl+I toggles a floating ChatGPT pane in the right third of the screen,
Cmd+Alt+Ctrl+U a Yandex Translate pane in the left third. Each window's toolbar
carries back/forward/reload and a URL bar, which wants a full address with the
scheme. AeroSpace is asked to move the pane to the current workspace, so it
opens in front of whatever work is on screen.
