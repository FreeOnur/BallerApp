> This workflow is automatically enforced by `.cursor/rules/00_global_workflow_rule.md`.
# Development Workflow — Baller App

Follow this workflow when using AI or making changes. Rules in `.cursor/rules/` enforce it.

---

## Before Coding
1. Always read project files before implementing features.
Follow project vision and user stories strictly.
2. **Read rules** — Skim `.cursor/rules/00_global_rules.md` through `10_performance_rules.md`. Lower number wins on conflict.
3. **Analyze code** — Locate existing logic and UI; avoid duplicating or rewriting working code.
4. **Plan small change** — Prefer minimal, safe edits. When unsure, ask before large refactors.

---

## After Coding

1. **Update changelog** — Append to `.cursor/ai/changes/changelog.md`:
   - file(s) changed
   - reason
   - impact (UI only, service, security, etc.)
2. **Store prompt** — Append to `.cursor/ai/prompts/prompt_history.md` a short summary of the user request (and key decisions if relevant).
3. **Verify security** — Run through the checklist in `.cursor/ai/security/security_checks.md` (auth, validation, secrets, RLS, async, logging).
4. **Explain shortly** — Summarize what was modified; do not rewrite existing app logic.

---

## Reference

- **Rules:** `.cursor/rules/`
- **Project context:** `.cursor/ai/context/project_context.md`
- **Security:** `.cursor/ai/security/security_checks.md` and `.cursor/rules/06_security_rules.md`
