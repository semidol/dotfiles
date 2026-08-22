---
name: solidity-finding-verdict
description: Judge an audit finding against the code, then record it as an accepted risk. User-invoked.
---

# Solidity Finding Verdict

An audit finding is a claim about code, not a fact about it. The user arrives with the finding and their own read of it — usually that the reported fix is wrong, or that the case is out of scope. Your job is the **verdict**: does the code back them, or the auditor?

The user is deciding whether to accept the risk. That decision is theirs, so the loop hands back control at every point where they might disagree.

## 1. Read the code before answering

Read the finding, then the functions it names and their callers. The finding's claim and the user's rebuttal are both hypotheses.

Check what the finding leaves out — the recovery path is the usual gap. An admin setter, a permissionless retry, or a state field written before the external call each change the verdict. Find the ordering that decides it: a status set before a failing call bricks the contract, set after it leaves the call retryable.

Done when you can name the lines that settle each statement, and the recovery path if one exists.

## 2. Give the verdict

Yes or no per statement, each with a short reason from the code. Nothing longer unless asked — the user reads the code too, and asks when they want more.

Correct the user where the code disagrees, including when they are right for the wrong reason. An overstated finding is still a real gap if it depends on a trusted admin acting; say so rather than endorsing "not an issue".

## 3. Answer questions until it's settled

The user drives. They ask about a statement, challenge the verdict, or move to recording it. Nothing gets written until they ask for it.

## 4. Write it to the README

The README is where audit contests look for accepted risks; **Sherlock treats it as the only authoritative source**, and Code4rena points wardens at it. Neither defines a template.

Add the entry under a `## Known Issues & Accepted Risks` heading, with a `###` heading per finding, as three plain paragraphs — no bold field labels:

- **What breaks**, including what users lose and who they must trust. State the trust cost here rather than as its own paragraph.
- **How it's recovered** — the concrete calls, and why they work.
- **Why it stays unfixed** — the user's reasoning, in their words, not yours.

Claim only mitigations the code has. A multisig or timelock that isn't wired up is a deployment note at most.

Done when each paragraph says something the others don't, and the entry reads without its labels.
