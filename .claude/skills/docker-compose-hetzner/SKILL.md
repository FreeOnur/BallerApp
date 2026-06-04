---
name: docker-compose-hetzner
description: Deploy BallerApp backend with Coolify and root docker-compose.yml on Hetzner.
---

## Stack

- `docker-compose.yml` at repo root: `db` (PostGIS) + `api` (FastAPI)
- Coolify: HTTPS proxy, env vars, no Caddy in repo

## Coolify

1. Base Directory: empty
2. Compose: `docker-compose.yml`
3. Env: `POSTGRES_*`, `JWT_SECRET`, `B2_*` (`courtfinder-image`)
4. Domain: `api.ballup.net` → `api:8000`

See root `README.md`.

## Commands

```bash
docker compose logs -f api
docker compose exec db psql -U baller -d baller -c "SELECT COUNT(*) FROM courts;"
```
