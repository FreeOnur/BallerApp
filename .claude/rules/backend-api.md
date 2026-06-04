---
paths:
  - backend/**
  - backend/app/routers/**
---

# FastAPI Backend

## Layout

- App: `backend/app/main.py` — CORS from `app/config.py` · routers `auth`, `courts`, `profiles`, `uploads`.
- DB: `get_conn()` in `app/db.py` · migrations in `backend/migrations/`.
- Auth: Argon2id (`app/security/passwords.py`) · JWT (`app/security/jwt.py`) · `HTTPBearer` in `dependencies.py`.

## New endpoints

1. Pydantic model + route in `backend/app/routers/<name>.py`.
2. SQL against tables in `001_initial.sql` (or new numbered migration).
3. Mirror in `baller_app/lib/repositories/<name>_repository.dart`.
4. Local test: `docker compose -f backend/docker-compose.dev.yml up -d` → `http://localhost:8000/docs`.

## Do not

- Expose Postgres publicly in prod (`docker-compose.prod.yml` internal network only).
- Return stack traces in production.
