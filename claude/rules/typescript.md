---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript

- Never use the non-null assertion operator (`!`). Use optional chaining (`?.`), nullish coalescing (`??`), or explicit null/undefined checks instead.
- Prefer `: Type` annotations or constructors over `as Type` casts. Never use `as` for type assertions. If a value is unknown, treat it as truly unknown — define and validate its shape explicitly (e.g., with a type guard or a runtime validator like Zod) rather than asserting a type.
- Prefer the most precise types available — avoid `any`. Use `unknown` at boundaries and narrow with type guards.
