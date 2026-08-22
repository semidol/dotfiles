---
name: lint-fix
description: Run the project linter and fix errors or explain why they can't be fixed
---

# Lint Fix

1. Read CLAUDE.md to find the lint command (look for a line like "Lint command: ..." or "Lint: ...").
   If not found, ask the user what command to use before proceeding.
2. If the user provided a file path, scope the lint command to that file. Otherwise run it on the whole project.
3. For each error, choose one of two approaches:
   - **Fix it** — if the fix is clean and straightforward. Report what was changed and why.
   - **Explain and ask** — if the fix would be large/ugly, requires a design decision (e.g. choosing between a type-level refactor vs. a lint disable comment), adding any lint disable/suppress comment, or if an initial fix attempt causes new type errors. **Stop immediately. Do not make further edits.** Explain what you found, list the options with tradeoffs, and explicitly ask the user which path to take before touching any file.
4. After handling all errors, re-run the lint command to confirm no errors remain.
