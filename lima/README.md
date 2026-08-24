# Dev VM

An isolated Ubuntu VM for running Claude without permission prompts. The guest
has no access to the host filesystem and cannot reach the local network, so a
misbehaving agent is confined to the VM.

## How work moves

The VM has no git credentials and no route to any remote. Everything travels
through the host, which drives both directions over Lima's own SSH channel:

```
GitHub  <--->  ~/repos/<name>.git  <--->  guest ~/projects/<name>
               (bare, on the host)         (where the agent works)
```

The host bare repo is the durable copy. Projects with no GitHub remote live
only there, so an unsynced VM is an unbacked-up VM.

Guest commits reach the host as refs and are never checked out, so code
written in the VM cannot execute on the host. Review diffs before merging,
and build or run guest code only inside the VM.

## Daily use

```sh
devsh        # zsh inside the VM (alias for limactl shell --shell /usr/bin/zsh dev)
tmux-pick    # pick a project, opens a tmux session with nvim + claude-tuned
```

On the host, to move work out of the VM and on to GitHub:

```sh
proj-sync <name>          # guest dev -> host bare repo -> origin
proj-sync <name> --down   # host dev -> guest, after merging on GitHub
```

Merge `dev` into `main` with a pull request; nothing pushes `main` for you.

Shut down with `limactl stop dev`. The disk persists; running processes and
tmux sessions do not, so run `proj-sync` before stopping.

`claude-tuned` runs with `--dangerously-skip-permissions`. That is only safe
because it runs in here.

## First-time setup

```sh
limactl create --tty=false --name=dev ~/dotfiles/lima/dev.yaml
limactl start dev
```

Provisioning installs docker, node (fnm), foundry, neovim, tmux and the Claude
CLI. Then, from the host, seed the VM with the dotfiles:

```sh
proj-new dotfiles https://github.com/semidol/dotfiles.git
limactl shell dev ln -s projects/dotfiles dotfiles
limactl shell dev ./dotfiles/lima/bootstrap-dotfiles.sh
```

The symlink is what keeps `~/dotfiles` valid: the repo lives under
`~/projects` like every other project, but bootstrap and the shell config
both expect it at `~/dotfiles`.

`proj-new` also adds `Include ~/.lima/dev/ssh.config` to `~/.ssh/config` on
first run, which is what lets git address the guest at all.

## Starting a project

```sh
proj-new <name> [github-url]
```

With a URL the bare repo is cloned from GitHub and the guest is seeded from
it. Without one the project starts empty and stays local to this machine.
Either way the guest starts on `dev`.

`proj-new` asks which identity to commit as: `global`, or any file in
`~/.config/git/identities/`. Each is a gitconfig fragment holding a `[user]`
block; drop in another file and it appears as an option.

## Files

| File | Purpose |
| --- | --- |
| `dev.yaml` | VM definition: no mounts, no SSH agent forwarding |
| `provision-firewall.sh` | Rejects RFC1918 destinations; runs on every boot |
| `provision-system.sh` | Root-level toolchain, runs once at creation |
| `provision-user.sh` | Node, foundry; runs once |
| `bootstrap-dotfiles.sh` | Symlinks configs, installs plugins; run manually |

Host-side scripts live in `bin/`: `proj-new`, `proj-sync`, and `proj-selftest`,
which exercises both against a throwaway project.

## Things that will bite

Provisioning scripts run **only at VM creation**, not on restart. After editing
one, either apply the change by hand or recreate the VM.

Lima appends a PATH block to `~/.zshrc` on boot, which shows up as an
uncommitted change in the guest's dotfiles clone. Discard it before syncing:

```sh
git checkout zsh/.zshrc
```

The firewall rules live inside the guest, so root in the VM can flush them.
They stop accidental and opportunistic LAN access, not a deliberate escape.

Nothing in the VM is backed up. Run `proj-sync` often.
