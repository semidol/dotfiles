---
name: refactor
description: Refactor code to be cleaner and better organized without changing its behavior. Use whenever the user asks to refactor, clean up, tidy, restructure, reorganize, or improve readability of existing code — even if they don't say "refactor" (e.g. "this file is a mess", "make this more readable", "reorder these functions").
---

# Refactor

Improve how code reads and is organized **without changing its behavior**. Preserve behavior, match the existing style, and verify with tests/linter afterward.

## Clean code principles

- **Meaningful names** — reveal intent, no comment needed.
- **Small functions, one job** — single thing, single level of abstraction.
- **DRY** — factor real duplication; don't over-abstract.
- **Comments explain *why*, not *what*** — delete comments that just restate code.
- **No magic numbers** — use named constants.
- **Minimal side effects** — no hidden surprises.
- **Explicit error handling** — don't swallow errors.
- **Low coupling, high cohesion** — depend on little; keep related things together.
- **KISS / YAGNI** — simplest thing that works.
- **Readable formatting** — blank lines between logical blocks.

## Code ordering within a file

- **Newspaper order** — high-level first, details below.
- **Caller before callee** — read in the direction of the call.
- **Public before private** — exported members above helpers.
- **Keep related code close** — less scrolling to understand a unit.
- **Group by feature, not by kind** — cohesion over "all constants here, all helpers there".
- **Declare near first use** — not all bunched at the top.
- **Single-use helpers beside their caller.**

