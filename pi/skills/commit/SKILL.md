---
name: commit
description: Creates all commits in this repo. Splits pending changes into one or more Conventional Commits. Use whenever a commit is about to be made — asked directly ("commit", "stage and commit", "make a commit"), or reached at the end of some other task. Never write a commit message or run git commit outside this skill.
---

# Commit

Create one Conventional Commit per logical change. The subject describes what changed; the body explains the reason when known and useful.

Work silently except when asking about missing reasons and reporting the final result.

## Workflow

1. Identify every logical change from the conversation, including features, refactors, fixes, deletions, and config changes. If the history may be incomplete, include "unknown other changes".

2. Find each change's reason in the invocation or conversation. Ask once about all missing reasons, with enough context to answer each question. If no reason is provided, use a factual subject and omit the body. Never infer reasons from the diff, git history, other commits, or unrelated discussion.

3. Inspect the changes:
   ```sh
   git status --short
   git diff
   git diff --staged
   git log --oneline -n 20
   git branch --show-current
   ```
   Use history only for vocabulary and granularity; always use Conventional Commits.

4. Create a separate commit for each logical change. Split by intent, not by files. Combine changes only when their hunks cannot reasonably be separated. Stage exactly the relevant files or hunks, then commit using the format below.

5. Run `git log --oneline -n <count>` and report only the commit count and subjects.

## Message format

```
<type>[(<scope>)][!]: <description>

[optional body]

[optional footer(s)]
```

### Type

- `feat`: feature; `fix`: bug fix; `docs`: documentation
- `style`: formatting; `refactor`: restructuring without behavior change; `perf`: performance
- `test`: tests; `build`: build system or dependencies; `ci`: CI configuration
- `chore`: maintenance; `revert`: revert a previous commit

### Scope and description

Use an optional scope naming the affected area. Write the description in lowercase imperative mood, without a trailing period. Keep the whole subject within 72 characters and describe what changed, not why.

### Body

Include a body only when a stated reason adds information beyond the subject. Start with the reason, not implementation details. Preserve the user's meaning without additions; use one or two sentences, or short bullets for multiple points. Omit mechanical details already visible in the diff. Add a blank line after the subject and wrap at about 72 columns.

### Breaking changes

Append `!` before the colon or add a `BREAKING CHANGE: <description>` footer. With `!`, the description must describe the break. Prefer the footer when it needs a paragraph.

### Footers

Place footers one blank line after the body. Use `Token: value` or `Token #value`, replacing spaces in tokens with `-`; values may span multiple lines.

## Hard rules

- **Never** use `--no-verify`. If a pre-commit hook fails, fix it only if clearly caused by your staging (e.g. a missed related file); otherwise report and stop.
- **Never** amend — always create new commits.
