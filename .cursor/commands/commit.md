# Commit Changes

Create a clean conventional commit. **Only when the user explicitly asks to commit.**

## Steps

1. `git status` · `git diff` · `git log -5 --oneline` (match repo style).
2. Never commit secrets (`.env`, keys, `courts.sql`).
3. Stage relevant files only — not unrelated noise.
4. Message: `type(scope): imperative description` per `conventional-commits.mdc`.
5. Caliber pre-commit hook syncs agent configs — commit normally if hook is active.
6. If no hook: `caliber refresh` then stage synced config files before commit.
7. `git status` after commit to verify success.

Do **not** push unless the user asks.
