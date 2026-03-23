# Logging Rules

After each modification:

1. **Changelog** — Append to `.cursor/ai/changes/changelog.md`:
   - file(s) changed
   - reason
   - impact (e.g. UI only, service, security)

2. **Prompt history** — Append to `.cursor/ai/prompts/prompt_history.md`:
   - short summary of the user request
   - (optional) key decisions made

Never log: tokens, passwords, PII, or full request/response bodies. See 06_security_rules and ai/security/security_checks.md.
