# Keyboard

Everything that decides which key does what on the host:

| Path | What |
| --- | --- |
| `karabiner/complex-modifications.json` | Karabiner-Elements group: hyper on right Command, Control ⇄ fn, Caps Lock → Esc |

The 36-key board's own layout is `keyboard-layout.vil` at the repository root
and is flashed to the board, not handled here.

## Karabiner Elements

One group, `karabiner/complex-modifications.json`, written for
Karabiner-Elements 16.3:

| Rule | What it does |
| --- | --- |
| Right Command | posts `left_command` + `left_control` + `left_option` while held |
| Control ⇄ fn | Control acts as fn (globe), fn acts as Control |
| Caps Lock | posts `escape`, the lock never engages |

## Install

```sh
mkdir -p ~/.config/karabiner/assets/complex_modifications
ln -sfn ~/dotfiles/keyboard/karabiner/complex-modifications.json \
  ~/.config/karabiner/assets/complex_modifications/complex-modifications.json
```

Then Karabiner-Elements → Complex Modifications → Add rule → the group
"Keyboard remaps (built-in keyboard)" → enable the rules you want.

Set System Settings → Keyboard → Modifier Keys to **Default** for every
keyboard. The swap is done here, so leaving the macOS swap in place applies it
twice.

## Why the macOS Modifier Keys panel is now empty

A Karabiner rule is not a filter in front of the keyboard: for every device it
is told to modify, Karabiner swallows the event and reposts it from its own
virtual keyboard (`Karabiner DriverKit VirtualHIDKeyboard`). The per-device
Modifier Keys panel is keyed to the *physical* device, so once events arrive
from the virtual keyboard that mapping no longer matches and silently stops
applying (Karabiner-Elements issues #9, #568, #3242).

The panel also cannot express what the hyper rule needs: it maps one modifier
to one modifier, never to a combination.

## Details worth knowing

Modifier `key_code`s in `to` are held for as long as `from` is held, so
releasing right Command releases all three modifiers. `"optional": ["any"]` lets
the rule fire with Shift or anything else already down. If right Command alone
produces a stray modifier event in some app, add `"lazy": true` to its `to`.

Events emitted by a `to` are not re-processed by other rules, so the
`left_control` in the hyper rule is not swapped into `fn` again.

The fn key arrives either as `key_code: "fn"` or, on Apple keyboards, as
`apple_vendor_top_case_key_code: "keyboard_fn"`; the rule matches both, so the
swap works whichever encoding the keyboard sends. Press fn and check
Karabiner-Elements → EventViewer if the direction fn → Control ever stops
working.

Caps Lock is intercepted before the lock engages, so the Caps Lock LED stays
off and no caps lock state is set. If Caps Lock toggling is still wanted on a
double tap, that needs a separate `to_if_alone` rule.

## Scope

Every manipulator carries `device_if: is_built_in_keyboard`, so the rules apply
to the built-in Apple keyboard and nothing else — any other keyboard is out of
reach even when its Devices checkbox is ticked. The Control → fn swap in
particular would rewrite the Control inside chords other keyboards send on
purpose.

Devices tab: tick only the keyboards Karabiner should touch. Unticking a device
makes Karabiner pass it through untouched. The 36-key board keeps its own
firmware layout (`keyboard-layout.vil`), which sends `left_meta` and its LCAG
layer, never `right_command`, `caps_lock` or `fn`.
