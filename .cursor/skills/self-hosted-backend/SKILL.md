---
name: self-hosted-backend
description: BallerApp self-hosted API on Hetzner with Coolify and docker-compose.yml at repo root.
---

# Self-Hosted Backend (BallerApp)

## Architecture

- **API**: `backend/app/` (FastAPI)
- **Deploy**: `docker-compose.yml` at repo root via Coolify
- **Flutter**: `--dart-define=USE_LEGACY_SUPABASE=false` + `API_BASE_URL=https://api.ballup.net`

## Local

```bash
docker compose up -d --build
```

## Cutover

1. `backend/scripts/export-from-supabase.md`
2. `backend/scripts/import-local.ps1`
3. Coolify env: `POSTGRES_*`, `JWT_SECRET`, `B2_*` (bucket `courtfinder-image`)

See root `README.md`.
