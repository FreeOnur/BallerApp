---
name: self-hosted-backend
description: BallerApp self-hosted API on Hetzner CPX22 with PostgreSQL+PostGIS in Docker. Use when adding REST endpoints, migrating off Supabase hosted DB, or editing backend/ and docker-compose files. Do NOT add Supabase client calls for new game/court/profile data — use lib/repositories/ and the FastAPI backend instead.
---

# Self-Hosted Backend (BallerApp)

## Architecture

- **API**: `backend/app/` (FastAPI) — sole DB access; Flutter never connects to Postgres directly.
- **DB**: PostgreSQL 16 + PostGIS in Docker (`backend/docker-compose.dev.yml`).
- **Deploy**: `backend/docker-compose.prod.yml` + `backend/Caddyfile` on Hetzner CPX22.
- **Flutter flag**: `USE_LEGACY_SUPABASE` dart-define; default `true` until cutover.

## Critical

- New features: add route in `backend/app/routers/`, migration in `backend/migrations/`, repository in `baller_app/lib/repositories/`.
- Secrets only in `.env` / server env — never commit `JWT_SECRET`, DB passwords, B2 keys.
- Match existing table shapes: `profiles`, `courts`, `court_images` (see `backend/migrations/001_initial.sql`).

## Local dev

```bash
cd backend
cp .env.example .env
docker compose -f docker-compose.dev.yml up -d
# API at http://localhost:8000/docs
```

## Cutover checklist

1. Export Supabase data (`backend/scripts/export-from-supabase.md`).
2. Import into local/prod Postgres (`backend/scripts/import-local.ps1`).
3. Run API + smoke-test `/health`, `/auth/login`, `/courts`.
4. Flutter: `--dart-define=API_BASE_URL=... --dart-define=USE_LEGACY_SUPABASE=false`.
