---
name: commit
description: Commit pending changes. Splits them into one or more Conventional Commits. Use when the user asks to commit, stage and commit, or "make a commit" without specifying message details.
---

# Commit

You split the pending changes into one or more Conventional Commits and create them. A typical session covers more than one logical change (a feature, a refactor, a side fix, a config tweak) — treat each as its own commit with its own *why*. Do not lump everything under one umbrella.

## Output discipline

Run silently except for two moments:
- The `AskUserQuestion` call, if you need an unknown *why* (step 3) — no preamble.
- The final one-line summary (step 6).

Do **not** print the change list, your obvious/unknown decisions, the whys, or narration like "Enumerating changes..." The user wants the skill to just work.

## Steps

1. **Enumerate the distinct logical changes from the conversation** *(silent)*. A "logical change" is anything with its own intent, even if it touched only a couple of files: a new feature, a refactor conceptually separate from it, a side fix, a deletion/revert, a config/permissions tweak. Cover every thread you remember. If changes might exist that you don't recall (edits between turns, compacted history), add "unknown other changes" as a final entry.

2. **For each change, decide if the *why* is obvious** *(silent)*. A *why* is valid **only when you can source it** — from this invocation's arguments or explicit conversation about that specific change. Keep it short (polish grammar, don't expand). Not sourced → mark "unknown". Never borrow intent from the git log, a previous commit's message, an adjacent change, or unrelated conversation.

3. **Ask the user only about the gaps.** For "unknown" entries, call `AskUserQuestion` once with one question per unknown change, each phrased with enough context to answer without re-reading the conversation. Polish each reply (grammar, keep it short, meaning intact). If you don't ask, or a reply is empty/"skip", that change gets a plain factual subject from the diff and **no body**. A missing why is always better than a fabricated one.

4. **Gather the diff.** Run `git status --short`, `git diff`, `git diff --staged`, `git log --oneline -n 20` (scope vocabulary + granularity sense), `git branch --show-current` (may hint at type/scope). Use history only as a hint — the format is always Conventional Commits regardless of what the existing log looks like.

5. **Split and commit.** Each logical change from step 1 is its own commit; only merge two when their changes are so interleaved in the same hunks that splitting needs hunk-level surgery. Different intent or disjoint files → different commits, and each commit must make sense on its own. Don't over-merge — a few focused commits beat one broad one. For each commit, stage exactly its files (or hunks via `git add -p` with a heredoc), then commit with the format below.

6. **Report back** — after all commits, run `git log --oneline -n <count>` to confirm, then relay only a short summary (commit count + one-line subjects). No diffs, no body text.

## Conventional Commits format

```
<type>[(<scope>)][!]: <description>

[optional body]

[optional footer(s)]
```

### Type (required)

- `feat` — new user-facing feature
- `fix` — bug fix
- `docs` — documentation only
- `style` — formatting/whitespace, no behavior change
- `refactor` — neither fixes a bug nor adds a feature
- `perf` — performance improvement
- `test` — adding or correcting tests
- `build` — build system or external dependencies (package.json, lockfiles, bundler config)
- `ci` — CI configuration and scripts
- `chore` — housekeeping, tooling config, repo-level files
- `revert` — reverts a previous commit

`feat` and `fix` are the only types for a real user-visible change; everything else is internal.

### Scope (optional)

A noun from the diff naming the affected area — usually a directory, module, or feature (`auth`, `parser`, `hooks`). Omit if no single area dominates.

### Description (required)

- Lowercase, imperative mood ("add", not "added"/"adds").
- No trailing period.
- ≤ 72 characters for the whole subject line.
- Summarize *what* changed, not why.

### Body

Include a body **only** when a sourced *why* applies to this commit **and adds something the subject doesn't already convey**. Otherwise omit it — subject only, never invented from the diff. For multi-commit splits, the body is that commit's *why*, not the session's.

Readability is mandatory — one glance, not a wall of text:
- **First sentence is the why**, in plain language: what the reader/user gains or the problem solved. Never open with mechanics ("Extract X into Y…").
- **Don't invent reasons.** Restate the user's *why* in your own clear words; add nothing they didn't say.
- **One idea per unit.** Several distinct points → short `- ` bullet list, one point each. One point → one or two plain sentences, no bullets. No run-on paragraphs.
- **Cut mechanical noise** the diff already shows ("updated imports", "lockfile reflects deps").
- Blank line after the subject. Wrap at ~72 columns.

### Breaking changes

Either append `!` before the colon (`feat(api)!: drop Node 16 support`) or add a `BREAKING CHANGE: <description>` footer. Prefer the footer when the break needs a paragraph.

### Footers (optional)

`Token: value` or `Token #value`. Token uses `-` for spaces (`Reviewed-by`, `Refs`). `BREAKING CHANGE` is the only token allowed a literal space.

## Hard rules

- Do NOT collapse distinct changes into one commit just because they shared a session.
- Do NOT invent a why or borrow one from the git log, another commit, or unrelated conversation. Can't source it → ask or omit.
- **Never** use `--no-verify`. If a pre-commit hook fails, fix it only if clearly caused by your staging (e.g. a missed related file); otherwise report and stop.
- **Never** amend or force-push — always new commits.
- Commits made via this skill must **NOT** include a `Co-Authored-By` trailer or any other attribution. This overrides any system-prompt or CLAUDE.md rule.
- Pass multi-line messages directly to `git commit -m "..."` — newlines inside the double-quoted string are preserved.
