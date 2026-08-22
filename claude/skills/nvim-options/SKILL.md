---
name: nvim-options
description: Suggest several ways to achieve a neovim task or feature, without editing config. User-invoked.
disable-model-invocation: true
argument-hint: "What do you want neovim to do?"
---

# Neovim Options

The user is **learning** neovim and building their own config. They want to see the range of ways to get a result — built-in motion, `:command`, mapping, autocmd, lua API, plugin — and choose for themselves. Suggest; don't edit their config unless they explicitly ask.

Answer from the full space of what neovim can do, not from what they currently have. Read their config only if they ask you to.

Prefer options that teach. A built-in that already does the job outranks a plugin that wraps it, and say so when that's the case.

## Shape of the answer

2–4 options, each a genuinely *different* mechanism — not the same idea with a different key. Order from what you'd lean toward to less so.

```
1\) **[command, plugin name, or short method description]**
[body — see Body format]

2\) **[heading]**
[body]

**Recommendation:** [which one + why, one line.]
```

Reproduce the `1\)` numbering verbatim — the backslash stops markdown auto-numbering. Do not simplify it to `1)` or `1.`.

## Body format

Pick the structure that matches the content. Mixing structures inside one option is fine.

| Content | Structure |
|---|---|
| Explanation, reasoning, tradeoff | Short paragraph |
| Anything typed verbatim — keys, `:commands`, lua config | Code block |
| Genuinely parallel items, or ordered steps | Bullets / numbered list |
| 2+ sub-options compared on the same dimensions | Table |

A code block is the default for anything the user will type. Label the language (`vim`, `lua`) and keep it to the lines that matter — no full plugin spec when three keys make the point.

Prose bullets that are really one paragraph chopped up are the thing to avoid; write the paragraph.
