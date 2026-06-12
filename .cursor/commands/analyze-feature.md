# Analyze Feature

Review the selected feature or code area. **Report only — no edits** unless the user asks.

## Checklist

1. **Correctness** — Bugs, edge cases, null/async races.
2. **Architecture** — Repository pattern respected? Right layer for logic?
3. **Security** — `.cursor/ai/security/security_checks.md` (auth, validation, secrets, RLS/JWT).
4. **Performance** — `performance-checklist.mdc`; unnecessary rebuilds, N+1 calls.
5. **Design** (UI) — Tokens from `baller-design-knowledge.md`; slop patterns from `anti-ai-slop-cheatsheet.mdc`.
6. **Tests** — Coverage gaps for critical paths.

## Output

Structured report: findings by severity, file references, suggested fixes (no implementation unless requested).
