# Dev VM

An isolated Ubuntu VM for running Claude without permission prompts. The guest
has no access to the host filesystem and cannot reach the local network, so a
misbehaving agent is confined to the VM.

## Daily use

```sh
devsh        # zsh inside the VM (alias for limactl shell --shell /usr/bin/zsh dev)
tmux-pick    # pick a project, opens a tmux session with nvim + claude-tuned
```

Shut down with `limactl stop dev`. The disk persists; running processes and
tmux sessions do not, so push your work first.

`claude-tuned` runs with `--dangerously-skip-permissions`. That is only safe
because it runs in here.

## First-time setup

```sh
limactl create --tty=false --name=dev ~/dotfiles/lima/dev.yaml
limactl start dev
```

Provisioning installs docker, node (fnm), foundry, neovim, tmux and the Claude
CLI. Then, inside the VM:

```sh
git clone https://github.com/semidol/dotfiles.git ~/dotfiles
~/dotfiles/lima/bootstrap-dotfiles.sh
```

The clone prompts for a GitHub username and token. Credentials are stored per
repository path, so a second account can be used for other repos without any
extra configuration.

## Files

| File | Purpose |
| --- | --- |
| `dev.yaml` | VM definition: no mounts, no SSH agent forwarding |
| `provision-firewall.sh` | Rejects RFC1918 destinations; runs on every boot |
| `provision-system.sh` | Root-level toolchain, runs once at creation |
| `provision-user.sh` | Node, foundry, git credential helper; runs once |
| `bootstrap-dotfiles.sh` | Symlinks configs, installs plugins; run manually |

## Things that will bite

Provisioning scripts run **only at VM creation**, not on restart. After editing
one, either apply the change by hand or recreate the VM.

Lima appends a PATH block to `~/.zshrc` on boot, which shows up as an
uncommitted change in the guest's dotfiles clone. Discard it before pulling:

```sh
git checkout zsh/.zshrc
```

The firewall rules live inside the guest, so root in the VM can flush them.
They stop accidental and opportunistic LAN access, not a deliberate escape.

Nothing in the VM is backed up. Push branches often.
