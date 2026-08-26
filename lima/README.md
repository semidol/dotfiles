# Dev VM

An isolated Ubuntu VM for running Claude without permission prompts. The guest
has no access to the host filesystem and cannot reach the local network, so a
misbehaving agent is confined to the VM.

It also holds no credentials. The host is the only side that talks to GitHub,
so an agent in the VM cannot push anywhere, and code moves in and out over a
git remote pointed at the VM itself.

## Daily use

```sh
vm           # zsh inside the VM, or `vm <instance>` for another one
tmux-pick    # pick a project, opens a tmux session with nvim + claude-tuned
```

Shut down with `limactl stop dev`. The disk persists; running processes and
tmux sessions do not, so push your work first.

`claude-tuned` runs with `--dangerously-skip-permissions`. That is only safe
because it runs in here.

## First-time setup

```sh
~/dotfiles/lima/setup-vm.sh
```

Creates the instance, starts it, pushes the dotfiles in and bootstraps them.
Safe to re-run: an existing instance is reused. Provisioning installs docker,
node (fnm), foundry, neovim, tmux and the Claude CLI.

## Working on a project

`vm-remote` points the remote at the VM with git's `ext::` transport, which
git refuses to use until it is allowed once on the host:

```sh
git config --global protocol.ext.allow user
```

This loosens a safety default: `ext::` runs whatever command a remote URL
names, and `user` only narrows that to remotes you act on yourself.

The VM has no GitHub access, so a repository gets there from the host:

```sh
cd ~/IT/some-project
vm-remote add          # creates ~/projects/some-project in the VM
git push dev-vm main
```

Bring the agent's commits back with a normal fetch:

```sh
git fetch dev-vm
git log dev-vm/main
```

The host then pushes onward to GitHub. Nothing enforces this on GitHub's side;
the VM simply has no way to reach it.

## Files

| File | Purpose |
| --- | --- |
| `dev.yaml` | VM definition: no mounts, no SSH agent forwarding |
| `setup-vm.sh` | Creates the VM and installs dotfiles into it |
| `provision-firewall.sh` | Rejects RFC1918 destinations; runs on every boot |
| `provision-system.sh` | Root-level toolchain, runs once at creation |
| `provision-user.sh` | Node and foundry, runs once at creation |
| `bootstrap-dotfiles.sh` | Links configs, installs plugins; run in the guest |

`bin/vm-remote` lives outside this directory because it is used from any
repository, not just this one.

## Things that will bite

Provisioning scripts run **only at VM creation**, not on restart. After editing
one, either apply the change by hand or recreate the VM.

Pushes into the VM are rejected while its working tree is dirty, because the
guest repo uses `receive.denyCurrentBranch=updateInstead` to check out what it
receives. Commit or discard in the guest first.

`~/.zshrc` in the guest is **not** a symlink into the repo. Lima appends a PATH
block to `.profile`, `.bashrc` and `.zshrc` on every boot, creating them if
absent, and a symlink would land that block in tracked files. Instead the guest
file sources the repo config, which Lima leaves alone once its own marker is
present.

The firewall rules live inside the guest, so root in the VM can flush them.
They stop accidental and opportunistic LAN access, not a deliberate escape.

Nothing in the VM is backed up. Push branches often.
