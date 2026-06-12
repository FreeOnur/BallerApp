# Security Checks — BallerApp

Use before considering a change complete. Cross-check with `.cursor/rules/security-baseline.mdc`, `auth-conventions.mdc`, and `.cursor/skills/security-hardening/SKILL.md`.

---

## Quick template

```markdown
## Security Review — [Date / Change summary]

- [ ] **Auth** — User id from session/JWT only; no client-supplied ids for ownership
- [ ] **Input validation** — Server-side validation in API/RPC; client validation is UX only
- [ ] **Secrets** — No keys/tokens in source; `--dart-define` / `.env` only
- [ ] **Authz** — Legacy: Supabase RLS + `auth.uid()`; API mode: JWT in `dependencies.py`, fail closed
- [ ] **Backend** — Argon2id passwords; short JWT TTL; refresh tokens hashed; CORS restricted in prod
- [ ] **Async safety** — Errors handled; no sensitive data in user-facing error strings
- [ ] **Logging** — No tokens, PII, or full bodies in logs (user IDs only)
- [ ] **HTTPS** — No plain HTTP for API or auth in production
- [ ] **Uploads** — Presigned URLs only; validate mime/size server-side
```

---

## 1. Input validation

- Validate and sanitize every user input (text, uploads, query params).
- Allowlists for fixed sets; length caps on free text.
- FastAPI: Pydantic models + server-side checks in routers/RPCs.

## 2. Auth and authorization

- **API mode:** `ApiAuthRepository` + `TokenStorage` (secure storage); refresh via `POST /auth/refresh`.
- **Legacy:** Supabase session via `onAuthStateChange`; RLS on every table.
- Sensitive ops (delete account, change email) require recent re-auth.

## 3. No secrets in code

- No Supabase service role, JWT secret, or B2 keys in client or committed files.
- `.env` in `.gitignore`; Flutter via `--dart-define`.

## 4. Data access boundaries

- No `Supabase.instance.client.from(...)` in widgets — use repositories.
- Service-role key never in Flutter app.

## 5. Safe async and errors

- Typed errors with context; `AsyncValue.error` preserves stack in Riverpod.
- Never silently swallow exceptions.

## 6. Logging and PII

- Log user UUIDs, not names/emails/locations.
- No `print()` in production — `dart:developer` `log()`.

## 7. Infrastructure (prod)

- TLS at reverse proxy; Postgres not public; rate-limit auth endpoints.
- See `docker-compose-hetzner` skill for deploy checklist.
