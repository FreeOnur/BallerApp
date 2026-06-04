---
paths:
  - baller_app/lib/auth/**
  - baller_app/lib/repositories/**
  - baller_app/lib/core/api/**
  - baller_app/lib/core/config/app_config.dart
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

- See root `README.md` (deploy section) — passwords not portable from Supabase.
