---
name: solidity-red-test
description: Write a failing Foundry test for a known bug or audit finding, then fix it. User-invoked.
---

# Solidity Red Test

A bug is only real once a test goes **red** on it. The loop below never runs ahead of the user: two gates hand control back, and the fix comes after the red, never before.

## 1. Explore

Read the finding, the implicated source, and the existing test file and its bulloak tree. The finding's claim is a hypothesis — confirm it against the code before writing anything.

Done when you can name the exact line that misbehaves and the config that reaches it.

## 2. Propose the tree branch and the asserts

Say where the case belongs in the `.tree` file, the branch to add, the setup that reaches the bug, and each assert — marking which one goes red today and which are sanity asserts that pass either way.

Prefer the simplest setup that still passes the contract's own validation. Where validation admits a degenerate config, that's usually a shorter path to red than an elaborate one.

## 3. Stop for approval

Present the plan and wait. The user approves or reshapes the tree and the setup before any code exists.

## 4. Implement and confirm red

Write the tree branch and the test, then run it. Report the failure message verbatim.

Done when the test fails on the asserted bug — not on a revert, a setup error, or a compile error. A test that fails for the wrong reason is not red; fix it and re-run.

## 5. Stop for the fix

Ask whether to fix it or leave it to the user. If you fix, keep it minimal and run the whole suite, not just the new test.

## 6. Review

Review the fix as a reviewer, not its author: whether the gate now matches the condition it should, what else the change touches (event shapes, transfer guards, downstream consumers), and which pre-existing quirks it exposes without worsening. State clearly if the fix is correct.
