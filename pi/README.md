# Pi

Personal Pi configuration: settings, package declarations, custom themes and
skills.

## Setup

The VM bootstrap configures Pi automatically:

```sh
~/dotfiles/lima/bootstrap-dotfiles.sh
```

To configure only Pi:

```sh
mkdir -p ~/.pi/agent
cp ~/dotfiles/pi/settings.json ~/.pi/agent/settings.json
rm -rf ~/.pi/agent/themes
ln -sfn ~/dotfiles/pi/themes ~/.pi/agent/themes
rm -rf ~/.pi/agent/skills
ln -sfn ~/dotfiles/pi/skills ~/.pi/agent/skills
pi update --extensions
```

Only selected configuration entries are linked or copied into the application
directory. The rest of `~/.pi/agent` remains writable runtime state.

- `settings.json` is **copied**, because Pi rewrites it at runtime. After
  changing settings through `/settings`, copy them back into this directory to
  save the changes.
- `themes/` is **symlinked**, so theme edits immediately live in the repo. Use
  `/reload` after changes if needed.
- `skills/` contains Pi's personal skills, available as `/skill:<name>`; run
  `/reload` after adding or changing a skill.
- Packages are declared in `settings.json`; `pi update --extensions` installs
  or reconciles them. Their npm files and `node_modules` are not tracked.

Credentials in `auth.json`, sessions, caches and other runtime files stay out
of the repository.
