---
paths:
  - baller_app/lib/auth/**
  - baller_app/lib/repositories/**
---

# Auth Conventions

## AuthGate (`auth_gate.dart`)

- Root from `main.dart` → `MaterialApp(home: AuthGate())`.
- **Legacy**: `StreamBuilder` on `onAuthStateChange` → `profiles` `.maybeSingle()`.
- **API**: session via `AuthRepository` / `TokenStorage` → profile via `ProfileRepository`.
- Loading → `CircularProgressIndicator`; no session → login; no profile → creation flow.

## AuthService

- Delegates to `AuthRepository` — UI must not call Supabase directly.

## Cutover

- See `docs/DEPLOY.md` — passwords not portable from Supabase.
