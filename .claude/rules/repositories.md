---
paths:
  - baller_app/lib/repositories/**
---

# Repository Layer

## Wiring (`repository_provider.dart`)

- `USE_LEGACY_SUPABASE=true` → `SupabaseAuthRepository` + Supabase queries in domain repos.
- `USE_LEGACY_SUPABASE=false` → `ApiAuthRepository` + Dio calls to `API_BASE_URL`.

## API mode endpoints

| Repo | Method | HTTP |
|------|--------|------|
| `ApiAuthRepository` | login/register | `POST /auth/login`, `/auth/register` |
| `ApiAuthRepository` | logout | `POST /auth/logout` |
| `ProfileRepository` | profile CRUD | `GET/PUT /profiles/me` |
| `CourtRepository` | list/create | `GET/POST /courts` |

## Patterns

- Return `List<Map<String, dynamic>>` or IDs from repos; map to `Court.fromMap` at UI call site.
- POST/insert bodies use snake_case DB keys (`has_markings`, `skill_level`).
- Tokens in `flutter_secure_storage` only — never `SharedPreferences`.

## Do not

- Add `Supabase.instance.client.from(...)` in widgets for new API-mode features.
- Duplicate profile insert outside `AuthRepository` / `AuthService`.
