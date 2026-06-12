# Project Context — BallerApp

Brief context for AI and developers. Update when architecture or conventions change.

## Stack

- **Flutter** (SDK ^3.9.0) — `baller_app/`
- **Backend (target):** FastAPI + PostgreSQL/PostGIS — `backend/` · `docker-compose.yml` at repo root
- **Legacy (cutover):** Supabase when `USE_LEGACY_SUPABASE=true`
- **Storage:** Backblaze B2 presign (`POST /uploads/presign`)
- **Maps / location:** `google_maps_flutter`, `geolocator` via `LocationService`
- **CI:** `peakoss/anti-slop@v0` on PR open/reopen

## Structure

| Layer | Path |
|-------|------|
| Entry | `baller_app/lib/main.dart` → `AuthGate()` |
| Auth | `lib/auth/` · `lib/repositories/*_auth_repository.dart` |
| API client | `lib/core/api/api_client.dart` · `token_storage.dart` |
| Repositories | `lib/repositories/` — **all new data access here** |
| Pages / widgets | `lib/pages/` · `lib/widgets/` — no direct Supabase/API |
| Models | `lib/models/` — `fromMap` / Freezed, no business logic |
| Theme / design | `lib/theme/` · **`baller_app/baller-design-knowledge.md`** |
| Backend | `backend/app/routers/` · `migrations/` |
| Legacy Supabase | `lib/supabase/` — only when legacy flag is on |

## Conventions

- Repository pattern enforced (ADR-0008): Widget → Notifier → Repository → API/Supabase.
- Auth: session/JWT only; never trust client-supplied user ids for ownership.
- Secrets: `--dart-define` or `backend/.env`; never commit keys.
- Design: custom design system, dark default, editorial-streetball — see Baller tokens + Hallmark for web/marketing.
- Rules: `.cursor/rules/` (`.mdc`); always-on: `global.mdc`, `00-baller-tokens-always.mdc`.
- Workflow: `.cursor/workflow.md`

## AI Workflow

Before coding: read project context, relevant rules/skills, analyze existing code, plan minimal change.

After coding: security checklist, changelog, prompt history (if significant), `flutter analyze`, conventional commit.
