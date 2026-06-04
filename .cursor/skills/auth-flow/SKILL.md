---
name: auth-flow
description: Authentication flows for BallerApp — Supabase legacy and self-hosted JWT API. Use when changing login, register, password reset, AuthGate, or lib/repositories/auth_repository.dart. Ensures tokens stay in secure storage and AuthGate routing stays correct.
---

# Auth Flow (BallerApp)

## Modes

| Mode | Flag | Implementation |
|------|------|----------------|
| Legacy | `USE_LEGACY_SUPABASE=true` (default) | `auth_service.dart` + Supabase Auth |
| Self-hosted | `USE_LEGACY_SUPABASE=false` | `ApiAuthRepository` → `POST /auth/login`, `/auth/register` |

## Self-hosted flow

1. Register: `POST /auth/register` → returns access + refresh tokens.
2. Login: `POST /auth/login` → tokens stored via `TokenStorage`.
3. API calls: `Authorization: Bearer <access>` in `ApiClient` interceptor.
4. Refresh: `POST /auth/refresh` when access expires.
5. Logout: `POST /auth/logout` + clear secure storage.

## AuthGate

- `auth_gate.dart`: if legacy → `onAuthStateChange`; if API → check `TokenStorage.hasValidSession()` then `profiles` via repository.
- Profile missing → `ProfileCreationPage`; else → `MainPage`.

## Password reset (API)

- `POST /auth/forgot-password` → email token (configure SMTP in prod `.env`).
- Users migrating from Supabase must reset password once (hashes not portable).

## Do not

- Store tokens in `SharedPreferences`.
- Skip `AuthGate` in `main.dart`.
- Duplicate profile insert logic outside `AuthService` / `AuthRepository`.
