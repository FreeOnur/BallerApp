---
name: postgres-migrations
description: Authors numbered SQL in `backend/migrations/` for PostGIS schema changes and keeps tables aligned with FastAPI routers (`backend/app/routers/`) and Flutter `Court.fromMap`. Use when user says 'migration', 'add table', 'schema change', 'ALTER TABLE', or edits `001_initial.sql`. Covers dev initdb apply via `docker-compose.yml`, manual prod apply, and Supabase import validation with `backend/scripts/import-local.ps1`. Do NOT use for route-only work, Flutter-only model changes without schema, or Supabase dashboard-only schema.
paths:
  - backend/migrations/**/*.sql
  - docker-compose.yml (repo root)
  - docker-compose.yml (repo root)
  - backend/scripts/import-local.ps1
  - backend/scripts/export-from-supabase.md
---
# Postgres Migrations

## Critical

- **Source of truth:** every schema change gets a new file under `backend/migrations/` with a three-digit numeric prefix and snake_case description (e.g. `002_court_notes.sql`). **Never rewrite** a migration that has already run on shared or production data — including `001_initial.sql`.
- **Do not apply schema only in the Supabase dashboard** without the same change in `backend/migrations/`. Hosted and self-hosted must stay aligned for `courts`, `profiles`, `court_images`.
- **Baseline:** read `backend/migrations/001_initial.sql` before any new migration. It defines extensions (`postgis`, `uuid-ossp`) and tables `users`, `refresh_tokens`, `profiles`, `courts`, `court_images`.
- **Column naming:** **snake_case** only (`has_markings`, `skill_level`, `created_at`). Match FastAPI SQL in `backend/app/routers/` and Flutter `Court.fromMap` map keys (`lat`, `lng`, `has_markings`).
- **Dev auto-apply is first-boot only:** `docker-compose.yml (repo root)` mounts `backend/migrations/` into `/docker-entrypoint-initdb.d/`. Postgres runs those files **only when the `pgdata_dev` volume is empty**. Existing volumes need manual `psql` (Step 5B).
- **Production:** `docker-compose.yml (repo root)` does **not** mount migrations. Apply SQL manually on the prod `db` service after deploy.
- **Auth cutover:** Supabase hosted user password hashes **cannot** be imported into self-hosted `users.password_hash` (Argon2id). See `README.md` and `backend/scripts/export-from-supabase.md`.
- **DB image:** PostGIS-enabled Postgres image in both compose files — required for `CREATE EXTENSION postgis`.

### Baseline tables (from `001_initial.sql`)

| Table | PK / FK | Notes |
|-------|---------|-------|
| `users` | `id UUID` default `uuid_generate_v4()` | `email` UNIQUE, `password_hash` |
| `refresh_tokens` | `user_id` → `users(id)` ON DELETE CASCADE | index `idx_refresh_tokens_user` |
| `profiles` | `id UUID` **no default** | must equal `users.id` after register/import; columns include `username`, `skill_level`, `avatar_url` |
| `courts` | `id UUID` default; `status` default `'pending'` | geo: `lat`/`lng` DOUBLE PRECISION; optional `lights`, `has_markings`, `surface`, `hoops`, `address`; indexes `idx_courts_status`, `idx_courts_lat_lng` |
| `court_images` | `court_id` → `courts(id)` ON DELETE CASCADE | `file_path`; index `idx_court_images_court` |

### `courts` columns ↔ API / Flutter

| SQL column | Create request / INSERT in `backend/app/routers/courts.py` | Supabase create key in `baller_app/lib/repositories/` |
|------------|---------------------------------------------------------------|--------------------------------------------------------|
| `source` | hardcoded `'community'` | `'community'` |
| `name`, `lat`, `lng`, `indoor` | same | same |
| `lights` | `lights` | `lights` |
| `has_markings` | `has_markings` | `has_markings` |
| `surface`, `hoops`, `address` | optional | optional |
| `status` | `'pending'` on POST; list uses `'approved'` | `eq('status', 'approved')` on read |

PostGIS is enabled but **nearby queries today use `lat`/`lng`**, not `geometry`. Add a `geom` column in a new migration only when you also update courts router queries.

## Instructions

1. **Inventory impact (read before writing SQL)**
   - Open `backend/migrations/001_initial.sql` and list affected tables/columns.
   - Grep API usage:

```bash
cd backend && grep -r "FROM courts\|FROM profiles\|FROM users\|INSERT INTO" app/routers/
```

   - Grep Flutter keys:

```bash
cd baller_app && grep -r "has_markings\|fromMap" lib/
```

   - **Verify:** written list of tables, new columns, and downstream files (`backend/app/routers/`, `baller_app/lib/models/Court.dart`) before Step 2.

2. **Pick the next migration number**

```bash
cd backend/migrations && ls *.sql
```

   - Next file: lowest unused `NNN_*.sql` after `001_initial.sql`.
   - **Verify:** filename sorts lexicographically after existing files (initdb runs in sort order on fresh DB).

3. **Author the migration file** (uses Step 2 filename)
   - Path: `backend/migrations/NNN_description.sql`.
   - Header comment: purpose and date.
   - Match baseline DDL style from `001_initial.sql`:

```sql
-- 002_add_example.sql — purpose, YYYY-MM-DD
CREATE TABLE IF NOT EXISTS example (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_example_created ON example(created_at);
```

   - New FKs: `REFERENCES parent(id) ON DELETE CASCADE` like `court_images` in `001_initial.sql`.
   - New nullable columns on existing tables:

```sql
ALTER TABLE courts ADD COLUMN IF NOT EXISTS notes TEXT;
```

   - Index naming: `idx_{table}_{column}` (e.g. `idx_courts_status`).
   - **Verify:** every new column name is snake_case; FK targets exist in prior migrations.

4. **Align FastAPI and Flutter (uses Step 3 columns)**
   - Update parameterized SQL in `backend/app/routers/` (never f-string SQL; use `%s` placeholders via `get_conn()`).
   - If `courts` columns change: update `CreateCourtRequest` and INSERT in `backend/app/routers/courts.py`.
   - If `profiles` columns change: update Pydantic models and upsert in `backend/app/routers/profiles.py`.
   - If exposed to the app: extend `factory Court.fromMap` in `baller_app/lib/models/Court.dart` with `map['snake_case_key']`.
   - If legacy Supabase mode must stay aligned: update insert maps in `baller_app/lib/repositories/court_repository.dart`.
   - **Verify:** `docker compose up -d` then `curl -s http://localhost:8000/health` returns `{"status":"ok"...}` after router changes.

5. **Apply migration locally**

   **A — Fresh database (runs all files in `backend/migrations/` via initdb):**

```bash
cd backend
docker compose -f docker-compose.yml down -v
docker compose -f docker-compose.yml up -d --build
```

   **B — Existing `pgdata_dev` volume (incremental file from Step 2):**

```powershell
cd backend
Get-Content migrations\002_your_change.sql | docker compose -f docker-compose.yml exec -T db psql -U baller -d baller
```

   - **Verify:**

```bash
cd backend
docker compose -f docker-compose.yml exec db psql -U baller -d baller -c "\dt"
docker compose -f docker-compose.yml exec db psql -U baller -d baller -c "\d courts"
```

   - Confirm new table/column appears before Step 6.

6. **Supabase import validation (when migrating hosted data)**
   - Export: follow `backend/scripts/export-from-supabase.md` (tables `courts`, `profiles`, `court_images`).
   - Import:

```powershell
cd backend\scripts
.\import-local.ps1 -SqlFile .\supabase-data.sql
```

   - **Verify** row counts match hosted project:

```sql
SELECT 'courts' AS t, COUNT(*) FROM courts
UNION ALL SELECT 'profiles', COUNT(*) FROM profiles
UNION ALL SELECT 'court_images', COUNT(*) FROM court_images;
```

   - **Verify:** `profiles.id` values either have a matching `users.id` after cutover registration, or you are still in legacy Supabase-auth mode per `README.md`.

7. **Production apply (uses Step 3 file; manual — no initdb mount)**

```powershell
cd backend
Get-Content migrations\002_your_change.sql | docker compose -f docker-compose.yml exec -T db psql -U baller -d baller
```

   - Take backup first (`README.md` pg_dump cron pattern).
   - **Verify:** `curl -f https://api.yourdomain.com/health` and spot-check affected endpoints in `/docs`.

## Examples

### Example: Add optional `notes` on `courts`

**User says:** "Add a notes field to courts."

**Actions:**
1. Create `backend/migrations/002_court_notes.sql` with `ALTER TABLE courts ADD COLUMN IF NOT EXISTS notes TEXT;`.
2. Add `notes: str | None = None` to `CreateCourtRequest` and include `notes` in INSERT in `backend/app/routers/courts.py`.
3. Apply on dev:

```powershell
cd backend
Get-Content migrations\002_court_notes.sql | docker compose -f docker-compose.yml exec -T db psql -U baller -d baller
```

4. `curl -s http://localhost:8000/docs` → exercise `POST /courts` with Bearer token.

**Result:** Column exists in Postgres; API accepts optional `notes`; no Supabase-only drift.

### Example: New `game_sessions` table (API-only data)

**User says:** "Add a table for ranked game sessions."

**Actions:**
1. Create `backend/migrations/003_game_sessions.sql` with UUID PK, `TIMESTAMPTZ NOT NULL DEFAULT NOW()`, FKs to `courts(id)` and `users(id)` ON DELETE CASCADE.
2. New router under `backend/app/routers/` + `app.include_router` in `backend/app/main.py` (see `fastapi-router` skill).
3. **Do not** expose table to Flutter via Supabase client — use repositories + API only.

**Result:** Schema in repo; Flutter talks to FastAPI, not raw Postgres.

## Common Issues

- **`relation "courts" already exists` on fresh install** — You edited `001_initial.sql` instead of adding `002_*.sql`. Restore baseline from git; put additive DDL in a new numbered file.
- **New migration never runs after `docker compose up`** — `pgdata_dev` already initialized. Use Step 5B `psql` pipe, or `docker compose -f docker-compose.yml down -v` (destroys local data).
- **`relation "courts" does not exist`** — Migrations never applied. Recreate dev DB (Step 5A) or apply manually: `docker compose -f docker-compose.yml exec db psql -U baller -d baller -f /docker-entrypoint-initdb.d/001_initial.sql`.
- **`ERROR: extension "postgis" is not available`** — DB service must use PostGIS image from compose files, not plain `postgres` image.
- **`UndefinedColumn: column "notes" of relation "courts" does not exist`** in API logs — Router references column before migration applied. Run Step 5B before testing endpoints.
- **`insert or update on table "court_images" violates foreign key constraint`** on import — Import `courts` before `court_images`; ensure UUIDs match `backend/scripts/export-from-supabase.md` table list.
- **`Key (id)=(...) is not present in table "users"` when inserting `profiles`** — After self-hosted cutover, each `profiles.id` needs a `users` row (register flow in `backend/app/routers/auth.py` inserts both). Legacy import: import profiles only during hybrid window (`AUTH_CUTOVER.md`).
- **`column "has_markings" does not exist`** — Hosted DB missing column; add migration file, apply to self-hosted DB, then re-export — do not rename to camelCase in SQL.
- **`FATAL: password authentication failed for user "baller"`** — Match `POSTGRES_USER`/`POSTGRES_PASSWORD` in `backend/.env` with `docker compose -f docker-compose.yml exec db psql -U baller -d baller`.
- **`Connection refused on port 5432`** — Start DB: `docker compose up -d db`; wait for healthcheck: `docker compose -f docker-compose.yml ps`.
- **Prod schema drift** — production compose has no migrations volume; run Step 7 manually after each new numbered SQL file.
- **Supabase passwords do not work on API login** — Expected; users need password reset on API per `README.md`, not a migration fix.