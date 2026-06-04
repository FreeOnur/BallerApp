# BallerApp

Pickup basketball — courts, games, community.

## Deploy (Coolify)

| Setting | Value |
|---------|--------|
| Base Directory | empty (repo root) |
| Docker Compose | `docker-compose.yml` |
| Domain | `api.ballup.net` → service `api` → port `8000` → HTTPS |

Set in Coolify **Environment Variables**: `POSTGRES_*`, `JWT_SECRET`, `B2_*` (bucket `courtfinder-image`, EU endpoint from Backblaze bucket settings).

DNS: domain panel → A record `api` → server IP (not in Coolify).

## Local API

```bash
docker compose up -d --build
curl http://localhost:8000/health
```

## Flutter (own server)

```bash
cd baller_app
flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=https://api.ballup.net
```

Data migration: `backend/scripts/export-from-supabase.md`
