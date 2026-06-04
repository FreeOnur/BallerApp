# BallerApp — Claude Code

Pickup basketball: court discovery, ranked games, tournaments. Repo: `FreeOnur/BallerApp`.

## Stack

Flutter (`baller_app/pubspec.yaml`, SDK `^3.9.0`) · **legacy** `supabase_flutter` **or** self-hosted API (`backend/`, FastAPI + PostGIS) · `google_maps_flutter` · `geolocator` · B2 presign (`backend/app/routers/uploads.py` or edge fn) · Playwright (`package.json` → `@playwright/test`)

## Architecture

@./.cursor/project/architecture.md
@./.cursor/project/tech_stack.md
@./.cursor/project/product.md
@./docs/DEPLOY.md

| Layer | Paths |
|-------|-------|
| **Entry** | `baller_app/lib/main.dart` → `BadwordFilter.loadWords()` (`services/badword_filter.dart`) → optional Supabase init → `AuthGate()` |
| **Auth** | `baller_app/lib/auth/auth_gate.dart` · `auth_service.dart` |
| **API client** | `baller_app/lib/core/config/app_config.dart` · `core/api/api_client.dart` · `core/api/token_storage.dart` |
| **Repositories** | `repository_provider.dart` · `auth_repository.dart` · `api_auth_repository.dart` · `supabase_auth_repository.dart` · `court_repository.dart` · `profile_repository.dart` · `auth_result.dart` |
| **Backend** | `backend/app/main.py` → `routers/auth.py` · `courts.py` · `profiles.py` · `uploads.py` · `dependencies.py` · `db.py` · `security/jwt.py` · `security/passwords.py` |
| **Schema** | `backend/migrations/001_initial.sql` (`users`, `profiles`, `courts`, `court_images`, `refresh_tokens`) |
| **Models** | `baller_app/lib/models/Court.dart` — `factory Court.fromMap` (baseline: `id`, `name`, `lat`, `lng`, `indoor`; extend for `lights`, `has_markings`, `surface`, `hoops`, `address`) |
| **Services** | `baller_app/lib/services/load_position.dart` (`LocationService`) · `badword_filter.dart` |
| **Legacy Supabase** | `baller_app/lib/supabase/court_services.dart` — only when `USE_LEGACY_SUPABASE=true` |
| **Theme** | `baller_app/lib/theme/app_colors.dart` · `app_spacing.dart` · `app_sizes` |
| **Edge** | `baller_app/supabase/functions/get-upload-url/index.ts` · `config.toml` → `[functions.get-upload-url]` |
| **Deploy** | `docs/DEPLOY.md` · `docker-compose.coolify.yml` · `docker-compose.dev.yml` |
| **Import** | `backend/scripts/export-from-supabase.md` |

## Commands

### Flutter

```bash
cd baller_app && flutter pub get
cd baller_app && flutter analyze
cd baller_app && flutter test
```

```bash
cd baller_app && flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

```bash
cd baller_app && flutter run --dart-define=USE_LEGACY_SUPABASE=true --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Backend (local)

```bash
cd backend && docker compose -f docker-compose.dev.yml up -d --build
curl -s http://localhost:8000/health
```

```bash
cd backend/scripts && .\import-local.ps1
```

### Edge + e2e + Caliber

```bash
cd baller_app && supabase functions serve get-upload-url --no-verify-jwt
npx playwright test
caliber refresh --dry-run
```

## MCP (`.cursor/mcp.json`)

- **supabase** · **github** · **filesystem** · **browser** (`@playwright/mcp`)

## Conventions

- **New data/auth work**: `backend/app/routers/` + `baller_app/lib/repositories/*` — not new `Supabase.instance.client` calls
- **Auth flag**: `--dart-define=USE_LEGACY_SUPABASE` (default `true`); API mode uses `ApiAuthRepository` + `TokenStorage`
- **Token refresh gap**: `POST /auth/refresh` exists; wire in `api_client.dart` — not per-screen retries
- **Uploads**: B2 presign via `POST /uploads/presign` (API mode) or legacy edge fn
- **Models**: `Court.fromMap`; snake_case DB keys — align with `001_initial.sql` and repositories
- **Location**: `LocationService.loadPosition()` only — no raw `Geolocator` in widgets
- **Secrets**: `--dart-define` / `backend/.env` — never commit keys
- **Skills**: `repository-layer` · `fastapi-router` · `auth-flow` · `postgres-migrations` · `setup-caliber`
- **Learnings**: `CALIBER_LEARNINGS.md` when present

<!-- caliber:managed:pre-commit -->
## Before Committing

**IMPORTANT:** Before every git commit, ensure Caliber syncs agent configs.

```bash
grep -q "caliber" .git/hooks/pre-commit 2>/dev/null && echo "hook-active" || echo "no-hook"
```

- **hook-active**: commit normally; Caliber syncs via hook.
- **no-hook**: run `caliber refresh && git add CALIBER_LEARNINGS.md CLAUDE.md .claude/ .cursor/ 2>/dev/null` then commit.

Valid `caliber refresh` flags: `--quiet`, `--dry-run` only. `caliber config` is interactive (no flags).

If `caliber` missing: run `/setup-caliber`.
<!-- /caliber:managed:pre-commit -->

<!-- caliber:managed:learnings -->
## Session Learnings

Read `CALIBER_LEARNINGS.md` for project-specific patterns from prior sessions.
<!-- /caliber:managed:learnings -->

<!-- caliber:managed:model-config -->
## Model Configuration

Default: `claude-sonnet-4-6` with high effort. Pin via `/model` or `CALIBER_MODEL`.
<!-- /caliber:managed:model-config -->

<!-- caliber:managed:sync -->
## Context Sync

[Caliber](https://github.com/caliber-ai-org/ai-setup) keeps Claude/Cursor configs aligned; `caliber refresh` on pre-commit.
<!-- /caliber:managed:sync -->
