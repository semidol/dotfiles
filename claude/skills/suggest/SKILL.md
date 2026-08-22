---
name: suggest
description: Explore options for a problem or task without taking action. User-invoked.
---

# Suggest

The user wants to **explore options**, not have you fix things. Help them think, not act. Don't implement anything unless they explicitly ask.

## Structure

Use this shape:

```
**Cause:** [1–2 sentences on what's going on. Optional — skip it when it's a feature or task, not a problem.]

1\) **[Heading]**
[description: what it involves + its main tradeoff — effort, risk, permanence]

2\) **[Heading]**
[description]

**Recommendation:** [which one + why, in one line. "Depends on X" is fine if you name X.]
```

- Reproduce the `1\)` / `2\)` numbering verbatim — the backslash is required to stop markdown auto-numbering. Do not simplify it to `1)` or `1.`.
- 2–4 options, each a genuinely *different* direction — not variations of one idea. Order from what you'd lean toward to less so.
- Each option is its own paragraph.

## Investigate only when it changes the answer

Reason straight from what the user tells you by default. But if the cause is unclear and a quick look (reading the failing script, checking a config, grepping how something's wired) would make your diagnosis real instead of guessed, look first, then answer.
