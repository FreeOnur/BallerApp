# Security Checks — Baller App

Use this as a checklist when adding or changing code. AI and developers should run through it before considering a change complete.

---

## Automatic Security Review Template

When completing a task, fill this template (append to this file or keep in mind):

```markdown
## Security Review — [Date / Change summary]

- [ ] **Auth** — User id from session only; no client-supplied user ids for ownership
- [ ] **Input validation** — All user inputs validated/sanitized before use or send
- [ ] **Secrets** — No keys/tokens in source; env or secure config only
- [ ] **RLS / API auth** — Legacy: Supabase RLS + auth.uid(); Self-hosted: API enforces user id from JWT only
- [ ] **Backend** — Postgres not public; JWT secret strong; Argon2 passwords; Caddy TLS in prod
- [ ] **Async safety** — Errors handled; no uncaught Futures; no sensitive data in error messages
- [ ] **Logging** — No tokens, PII, or full request/response in logs
- [ ] **HTTPS** — No plain HTTP for API or auth
```

---

## 1. Input Validation

- Validate and sanitize every user input (text fields, file uploads, query params).
- Use allowlists for fixed sets of values; avoid passing raw user strings into queries or storage keys.
- Reject empty/whitespace-only where content is required.

## 2. Safe Async Handling

- Every `Future`/async call must have error handling (try/catch or .catchError).
- Do not expose internal errors or stack traces to the user in production.
- Prefer typed results (e.g. Result types) over throwing in public APIs.

## 3. No Secrets in Code

- No Supabase URL, anon key, or service role key hardcoded.
- Use environment variables or `flutter_dotenv` / build-time config; do not commit `.env`.
- If keys exist in repo today, plan migration to env and document in project_context.

## 4. Supabase RLS Awareness

- Assume Row Level Security is enabled on all tables.
- Queries must be written so they work under RLS (e.g. filter by `auth.uid()`).
- Never use service role in client app; no bypassing RLS from the app.

## 5. Safe Auth Usage

- Auth state and user id come only from Supabase session (e.g. `Supabase.instance.client.auth`).
- Do not trust user id or role from client payloads; derive from session in backend/services.
- Sign-out and token refresh handled via Supabase client; do not store tokens in plain text.

## 6. Prevent Unsafe Logging

- Do not log: auth tokens, passwords, full request/response bodies, PII.
- Do not print or debugPrint sensitive data; strip or redact in development if needed.
- See also: `.cursor/rules/09_logging_rules.md`.

---

Reference: `.cursor/rules/06_security_rules.md` for day-to-day security rules.
