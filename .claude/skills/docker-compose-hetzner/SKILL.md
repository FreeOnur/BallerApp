---
name: docker-compose-hetzner
description: Docker Compose and Hetzner CPX22 deployment for BallerApp backend (Caddy TLS, firewall, backups). Use when deploying backend/, configuring production compose, or hardening the VPS. Do NOT expose Postgres port 5432 publicly.
---

# Docker Compose + Hetzner CPX22

## Production stack

- `backend/docker-compose.prod.yml`: `api`, `db`, `caddy`.
- `backend/Caddyfile`: reverse proxy to `api:8000`, automatic HTTPS.
- Postgres bound to `127.0.0.1` or internal Docker network only.

## VPS setup (summary)

See `docs/DEPLOY.md` for full steps:

1. Non-root deploy user, SSH keys only.
2. UFW: allow 22 (restricted), 80, 443; deny 5432 from internet.
3. `docker compose -f docker-compose.prod.yml up -d` with `.env` on server.
4. Cron `pg_dump` → off-site backup (B2 or Hetzner Storage Box).

## Resource limits (4 GB RAM)

- Postgres: `shared_buffers=256MB`, `max_connections=50`.
- API: 1 worker uvicorn initially.
- Defer Authentik/Keycloak until RAM upgrade.

## Commands

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml logs -f api
```
