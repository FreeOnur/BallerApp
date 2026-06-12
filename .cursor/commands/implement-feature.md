# Implement Feature

Implement a feature from user stories using current BallerApp architecture.

## Before coding

1. Read `.cursor/project/architecture.md`, `tech_stack.md`, `product.md`, `user_stories.md`.
2. Read `.cursor/workflow.md` and relevant rules (especially `repositories.mdc`, `adr-0008`).
3. Load matching skill if applicable (`repository-layer`, `fastapi-router`, `auth-flow`, etc.).
4. For UI: read `baller_app/baller-design-knowledge.md`; apply Baller token rules.

## Implementation

1. Identify the requested feature in `user_stories.md`.
2. Trace existing code — extend, don't duplicate.
3. **Data:** Repository interface + provider; backend router if API mode.
4. **UI:** Pages/widgets only; state via Riverpod Notifiers.
5. **Errors:** Brand voice; no raw exception strings to users.
6. Run `cd baller_app && flutter analyze` (Dart changes).

## After

- Security checklist: `.cursor/ai/security/security_checks.md`
- Append `.cursor/ai/changes/changelog.md`
- Summary: files created/modified, next steps
