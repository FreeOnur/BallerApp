---
name: fastapi-router
description: Scaffolds FastAPI routes in `backend/app/routers/` matching `auth.py`, `courts.py`, and `profiles.py` with `get_conn()`, Pydantic request/response models, and `get_current_user_id`. Use when the user says "add endpoint", "new API route", "FastAPI handler", or edits `backend/app/main.py`. Capabilities: JWT-protected handlers, parameterized SQL, OpenAPI at `/docs`, Flutter repository path alignment. Do NOT use for Flutter UI, Deno edge functions (`baller_app/supabase/functions/`), or schema-only work without a route (use `postgres-migrations`).
paths:
  - backend/app/routers/**/*.py
  - backend/app/main.py
  - backend/app/dependencies.py
  - backend/app/db.py
---
# FastAPI Router (BallerApp)

## Critical

- **One router file per resource** under `backend/app/routers/`. Register every new router in `backend/app/main.py` via `app.include_router(...)`.
- **Database access only through `get_conn()`** from `app.db` (`backend/app/db.py`). Never call `psycopg2.connect()` in routers. Use `%s` placeholders — never f-string or concatenated SQL.
- **Schema first:** columns/tables must exist in `backend/migrations/` (baseline `001_initial.sql`: `users`, `refresh_tokens`, `profiles`, `courts`, `court_images`). New columns → `postgres-migrations` skill before the route.
- **Auth split:**
  - `backend/app/routers/auth.py` (`prefix="/auth"`): public register/login/refresh; use `backend/app/security/jwt.py` and `backend/app/security/passwords.py`; return `TokenResponse` with `response_model=`.
  - All other mutating or user-scoped routes: `user_id: Annotated[UUID, Depends(get_current_user_id)]` from `backend/app/dependencies.py` (`HTTPBearer`).
- **Response shape:** return `dict[str, Any]` or `list[dict[str, Any]]` via `dict(row)` (RealDictCursor). No ORM, no Supabase client in routers.
- **JSON keys:** snake_case in SQL and API bodies (`access_token`, `has_markings`) — matches Flutter `Court.fromMap` and `ApiAuthRepository._persistTokens`.
- **Config:** read secrets/URLs from `app.config.settings` only — never hardcode `DATABASE_URL` or JWT secrets.

## Instructions

### Step 1 — Confirm schema and route contract

1. Read `backend/migrations/001_initial.sql` (or latest `NNN_*.sql`) for table/column names.
2. Classify endpoint: **auth-only** (`/auth/*`), **public read** (`GET /courts`), or **JWT-protected** (`POST /courts`, `/profiles/me`).
3. Pick `APIRouter(prefix=...)` to match existing routers:
   - `auth.py` → `prefix="/auth"`, `tags=["auth"]`
   - `courts.py` → `prefix="/courts"`, `tags=["courts"]`
   - `profiles.py` → `prefix="/profiles"`, `tags=["profiles"]`
   - New resource → plural kebab-case URL segment (`/court-images`), Python module `court_images.py` (underscores).

**Verify** target table and columns exist in migrations before Step 2.

### Step 2 — Create or extend a router under `backend/app/routers/`

**Resource router boilerplate** (matches `courts.py` / `profiles.py`):

```python
from typing import Annotated, Any
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.db import get_conn
from app.dependencies import get_current_user_id

router = APIRouter(prefix="/courts", tags=["courts"])


class CreateCourtRequest(BaseModel):
    name: str
    lat: float
    lng: float
    indoor: bool = False
    lights: bool | None = None
    has_markings: bool | None = None
    surface: str | None = None
    hoops: int | None = None
    address: str | None = None


@router.get("")
def list_approved_courts() -> list[dict[str, Any]]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM courts WHERE status = %s ORDER BY created_at DESC",
            ("approved",),
        )
        return [dict(row) for row in cur.fetchall()]


@router.post("", status_code=status.HTTP_201_CREATED)
def create_court(
    body: CreateCourtRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, str]:
    court_id = uuid4()
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO courts (
                id, name, lat, lng, indoor, lights, has_markings,
                surface, hoops, address, source, status
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                str(court_id),
                body.name,
                body.lat,
                body.lng,
                body.indoor,
                body.lights,
                body.has_markings,
                body.surface,
                body.hoops,
                body.address,
                "community",
                "pending",
            ),
        )
    return {"id": str(court_id)}


@router.get("/{court_id}")
def get_court(court_id: UUID) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM courts WHERE id = %s", (str(court_id),))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Court not found",
            )
        return dict(row)
```

**Profiles `/me` pattern** (from `profiles.py`):

```python
router = APIRouter(prefix="/profiles", tags=["profiles"])


class UpdateProfileRequest(BaseModel):
    username: str | None = None
    skill_level: str | None = None
    # other fields: type | None = None


@router.get("/me")
def get_my_profile(
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM profiles WHERE id = %s", (str(user_id),))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        return dict(row)


@router.put("/me")
def upsert_my_profile(
    body: UpdateProfileRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO profiles (id, username, skill_level)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
                username = COALESCE(EXCLUDED.username, profiles.username),
                skill_level = COALESCE(EXCLUDED.skill_level, profiles.skill_level)
            RETURNING *
            """,
            (str(user_id), body.username, body.skill_level),
        )
        row = cur.fetchone()
    return dict(row)
```

**Auth router rules** (extend `auth.py` only — do not add `Depends(get_current_user_id)` on register/login):

| Route | Status | Pattern |
|-------|--------|---------|
| `POST /auth/register` | 201 | Insert `users` + stub `profiles` + `refresh_tokens`; `HTTP_409` if email exists |
| `POST /auth/login` | 200 | `verify_password`; `HTTP_401` on failure |
| `POST /auth/refresh` | 200 | Rotate refresh token; return `TokenResponse` |
| `POST /auth/logout` | 204 | Revoke refresh token; no response body |

```python
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    user_id: str


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest) -> TokenResponse:
    ...  # use app.security.passwords + app.security.jwt
```

**Pattern table (follow exactly):**

| Pattern | Source | Rule |
|---------|--------|------|
| Router | `courts.py` | `APIRouter(prefix="/courts", tags=["courts"])` |
| Public list | `courts.py` | `WHERE status = %s` with `("approved",)` |
| Create defaults | `courts.py` | `source="community"`, `status="pending"` |
| UUID PK | `courts.py` | `court_id = uuid4()`; SQL uses `str(court_id)` |
| Path UUID | `courts.py` | Param type `UUID`; bind `str(court_id)` |
| User scope | `profiles.py` | `/me` + `Depends(get_current_user_id)` |
| Upsert | `profiles.py` | `ON CONFLICT (id) DO UPDATE ... RETURNING *` |
| Patch fields | `profiles.py` | `field: type \| None = None` on update models |
| Auth JSON | `auth.py` | `TokenResponse` + `response_model=` |
| Auth errors | `auth.py` | 409 duplicate email; 401 bad credentials |

**Verify** imports are only `app.db`, `app.dependencies`, `app.config`, `app.security.*` — no Flutter or Supabase SDK.

This step uses the schema from Step 1.

### Step 3 — Register router in `backend/app/main.py`

1. Add import with existing routers:

```python
from app.routers import auth, courts, profiles, court_images  # new module
```

2. After CORS middleware, include router:

```python
app.include_router(auth.router)
app.include_router(courts.router)
app.include_router(profiles.router)
app.include_router(court_images.router)
```

**Verify** `rg include_router backend/app/main.py` lists the new router; Python module name matches filename (`court_images.py`, not `court-images.py`).

This step uses the router from Step 2.

### Step 4 — Run API locally and smoke-test

```bash
cd backend
copy .env.example .env
# Linux/macOS: cp .env.example .env
docker compose -f docker-compose.dev.yml up -d --build
curl -s http://localhost:8000/health
```

Expected: `{"status":"ok","environment":"development"}` (or equivalent from `main.py` health handler).

Open `http://localhost:8000/docs` — confirm new tag and paths.

JWT-protected route test:

```bash
curl -s -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"you@example.com\",\"password\":\"yourpassword\"}"

curl -s http://localhost:8000/profiles/me \
  -H "Authorization: Bearer <access_token>"
```

Public courts:

```bash
curl -s http://localhost:8000/courts
```

**Verify** protected routes without Bearer return `401` with `{"detail":"Not authenticated"}` from `get_current_user_id` in `backend/app/dependencies.py`.

This step uses the app from Step 3.

### Step 5 — Wire Flutter repository (client-facing endpoints only)

Map routes to `baller_app/lib/repositories/` (via `ApiClient` + `API_BASE_URL`):

| Endpoint | Repository method |
|----------|-------------------|
| `GET /courts` | `CourtRepository.fetchApprovedCourts()` |
| `POST /courts` | `CourtRepository.createCourt()` |
| `GET/PUT /profiles/me` | `ProfileRepository.hasProfile()` / `upsertProfile()` |
| `POST /auth/*` | `ApiAuthRepository` (not a domain repo) |

**Verify** `cd baller_app && flutter analyze` if Dart files change.

This step uses working routes from Step 4.

## Examples

### Example A — Public list approved courts (reference)

**User says:** "Add an endpoint to list approved courts."

**Actions:**
1. Confirm `courts.status` in `backend/migrations/001_initial.sql`.
2. Use `@router.get("")` + `WHERE status = 'approved'` in `backend/app/routers/courts.py`.
3. Router already registered in `backend/app/main.py`.
4. `curl -s http://localhost:8000/courts` → JSON array of snake_case court dicts.

**Result:** `GET /courts` matches `CourtRepository.fetchApprovedCourts()` and `Court.fromMap`.

### Example B — JWT-protected court submission

**User says:** "Add endpoint for users to submit a new court."

**Actions:**
1. Extend `CreateCourtRequest` and `@router.post("", status_code=201)` in `courts.py` with `Depends(get_current_user_id)`.
2. INSERT with `source='community'`, `status='pending'`, `id=uuid4()`.
3. Return `{"id": str(court_id)}`.
4. Test in `/docs` with Bearer from `POST /auth/login`.

**Result:** `POST /courts` creates pending row; `CourtRepository.createCourt()` can POST the same body keys.

### Example C — New `court_images` resource

**User says:** "Add API to attach an image path to a court."

**Actions:**
1. Confirm `court_images` (`court_id`, `file_path`) in migrations.
2. Create `backend/app/routers/court_images.py` with `prefix="/court-images"`, POST + JWT.
3. `app.include_router(court_images.router)` in `main.py`.
4. `curl -s -X POST http://localhost:8000/court-images -H "Authorization: Bearer ..." -H "Content-Type: application/json" -d '{"court_id":"...","file_path":"courts/abc.jpg"}'`.

**Result:** OpenAPI tag `court-images`; row in `court_images`.

## Common Issues

### `connection to server at "localhost" (::1), port 5432 failed: Connection refused`

1. `cd backend && docker compose -f docker-compose.dev.yml up -d`
2. `docker compose -f docker-compose.dev.yml ps` — `db` must be `healthy`
3. `.env` `DATABASE_URL`: inside API container use `postgresql://baller:baller@db:5432/baller`; host uvicorn uses `localhost:5432`

### `relation "courts" does not exist`

1. Migrations run on **first** empty `pgdata_dev` volume only (`docker-compose.dev.yml` mount)
2. Reset dev DB: `docker compose -f docker-compose.dev.yml down -v` then `up -d` (wipes local data)
3. Manual apply: `docker compose -f docker-compose.dev.yml exec db psql -U baller -d baller -f /docker-entrypoint-initdb.d/001_initial.sql`

### `401` / `{"detail":"Not authenticated"}`

1. Header: `Authorization: Bearer <access_token>` (not refresh token)
2. Obtain `access_token` from `POST /auth/login` or `/auth/register` JSON
3. `{"detail":"Invalid token"}` → token expired; call `POST /auth/refresh` with `refresh_token`

### `404` / `{"detail":"Court not found"}`

1. Confirm UUID exists: `docker compose -f docker-compose.dev.yml exec db psql -U baller -d baller -c "SELECT id FROM courts LIMIT 5;"`
2. URL path is bare UUID, not JSON-quoted

### `409` / `{"detail":"Email already registered"}`

Expected on duplicate `users.email`. User should login or use another email.

### New router missing from `/docs`

1. `app.include_router(...)` present in `backend/app/main.py`
2. Import: `from app.routers import your_module`
3. Bad import crashes API: `docker compose -f docker-compose.dev.yml logs -f api`
4. Rebuild if needed: `docker compose -f docker-compose.dev.yml up -d --build api`

### `ModuleNotFoundError: No module named 'app.routers.{name}'`

Python module file must use underscores (`court_images.py`), not hyphens.

### `psycopg2.errors.UndefinedColumn`

Column missing from DB — add `backend/migrations/NNN_*.sql` first; do not patch around in the router.

### `get_conn()` changes not persisted

`get_conn()` commits on successful context exit. For logic errors mid-handler, rely on exception — do not call `conn.commit()` manually unless matching an existing router pattern.