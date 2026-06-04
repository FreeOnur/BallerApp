---
name: postgres-migrations
description: PostgreSQL and PostGIS migrations for BallerApp self-hosted backend. Use when changing schema, adding game tables, importing Supabase data, or writing SQL in backend/migrations/. Do NOT edit schema only in Supabase dashboard without a matching migration file.
---

# Postgres Migrations (BallerApp)

## Layout

- `backend/migrations/001_initial.sql` — baseline `profiles`, `courts`, `court_images`, `users`, `refresh_tokens`.
- Apply order: numbered `NNN_description.sql`; never rewrite applied migrations.

## Apply locally

```bash
docker compose exec db \
  psql -U baller -d baller -f /migrations/001_initial.sql
```

Or mount migrations volume (see compose file).

## PostGIS

- Extension enabled in `001_initial.sql`.
- Court geo: `lat`/`lng` columns; use `ST_DWithin` for nearby queries when optimizing.

## Supabase import

1. Export with `backend/scripts/export-from-supabase.md`.
2. Import with `backend/scripts/import-local.ps1`.
3. Validate row counts for `courts`, `profiles`, `court_images`.

## New tables (game data)

- Prefer schema `game` or prefix `game_` tables in same DB.
- Grant access only through API service role — not from Flutter.
