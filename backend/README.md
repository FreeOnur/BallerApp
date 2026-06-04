# BallerApp Backend

FastAPI + PostgreSQL/PostGIS. Deploy: **[../docs/DEPLOY.md](../docs/DEPLOY.md)** (Coolify).

| Compose | Use |
|---------|-----|
| `../docker-compose.coolify.yml` | **Coolify** (Repo-Root, recommended) |
| `docker-compose.coolify.yml` | Coolify only if Base Directory = `backend` |
| `docker-compose.dev.yml` | Local test |
| `docker-compose.prod.yml` | Manual server + Caddy (no Coolify) |

Data export: `scripts/export-from-supabase.md`
