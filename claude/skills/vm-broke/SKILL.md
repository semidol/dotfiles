---
name: vm-broke
description: Diagnose something broken in the Lima dev VM after the move from the macOS host. User-invoked.
disable-model-invocation: true
---

# vm-broke

The user describes something that stopped working inside the Lima dev VM. Find the **missing link**: the one thing the guest lacks that the host had. Report it; change nothing.

## The move

Work moved from a macOS host to an Ubuntu Lima guest so agents can run `--dangerously-skip-permissions` against a machine they are allowed to destroy. The guest has no host mounts, no SSH agent, no credentials, and no LAN access. Everything the user's setup relies on either came in through `~/dotfiles` or did not come in at all.

So a breakage is almost always one of four missing links, in the order worth checking:

1. **Outside the repo.** The script calls something that lived on the host but was never tracked in `~/dotfiles`: a `~/bin` script, an app, a Homebrew formula, a file in `~/Library` or `~/.config` outside the linked dirs.
2. **macOS versus Linux.** `pbcopy`, `open`, `sed -i ''`, `brew`, `launchctl`, BSD flag spellings, `/opt/homebrew` paths, `darwin` branches, GNU coreutils differences.
3. **Setup never ran.** `lima/bootstrap-dotfiles.sh` links configs and installs plugins; `lima/provision-*.sh` run **only at VM creation**, so anything added to them since the instance was made is absent from a running guest.
4. **The boundary is doing its job.** No credentials, no GitHub reach, no host filesystem, firewall rejecting RFC1918. The thing "broken" may be the isolation working as designed.

`lima/README.md` documents the boundary and a "Things that will bite" section. Read it.

## Investigate

Reproduce the user's symptom first: run the command they named and capture the actual error. Then trace the call chain from that error outward — each hop is `caller → callee → where the callee is supposed to live → is it there`. Use `command -v`, `ls -l` on the symlinks bootstrap makes, `cat` the script, `uname`, `git log` on the suspect file.

Two facts worth checking early, since both silently rewrite the chain:

- Is the file a symlink into `~/dotfiles`, a stale copy, or absent? `bootstrap-dotfiles.sh` symlinks most Claude config but **copies** `settings.json`, and `~/.zshrc` is a real file that only sources the repo's.
- Was the guest created before the code you are reading was written? Compare the instance's age against the file's history.

Done when you can name the exact hop that fails and say why it fails there, not merely that the command errors.

## Report

Three sections, nothing else.

**What's broken** — one or two sentences.

**Chain** — numbered hops from invocation to failure, each naming the concrete file, binary, or path:

```
1. `start-work` calls `tmux-pick`
2. `tmux-pick` calls `fzf`
3. `fzf` is not installed in the guest — it came from Homebrew on the host and no provisioning script installs it
```

**Fix** — the shortest change that repairs it, and which file it belongs in (`provision-system.sh` for root-level tooling, `provision-user.sh` for user tooling, `bootstrap-dotfiles.sh` for links and plugins, the script itself for a macOS-ism). Say if it needs a VM recreate to take effect. One paragraph.
