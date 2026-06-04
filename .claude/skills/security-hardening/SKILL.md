---
name: security-hardening
description: Security hardening for BallerApp API, Flutter auth, Docker on Hetzner, and secrets management. Use for security reviews, auth changes, rate limits, TLS, OWASP API checks, or before production deploy. Cross-check backend/ and baller_app/lib/core/api/.
---

# Security Hardening (BallerApp)

## API (backend)

- JWT access tokens: short TTL (15 min); refresh tokens hashed in DB, rotatable.
- Passwords: Argon2id only (`backend/app/security/passwords.py`).
- Rate-limit login/register (per IP + email) — implement at reverse proxy or app layer.
- CORS: allow only production app origins in prod `.env`.
- No stack traces in production error responses.

## Flutter

- Tokens in `flutter_secure_storage` only (`lib/core/api/token_storage.dart`).
- API URL + flags via `--dart-define`, not hardcoded in `main.dart`.
- Remove Supabase anon key from source before production cutover.

## Infrastructure

- TLS via Caddy; HSTS enabled.
- Postgres not public; strong `POSTGRES_PASSWORD`.
- Rotate leaked keys in `.cursor/mcp.json`, Maps API keys, B2 credentials.

## Review checklist

Also read `.cursor/ai/security/security_checks.md` and verify:

- [ ] RLS replaced by API authorization checks per user id
- [ ] File uploads via presigned URLs only (B2 keys server-side)
- [ ] Dependency audit (`pip audit`, `dart pub outdated`)
- [ ] `caliber score` and CI tests green before deploy
