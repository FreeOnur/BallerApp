# Export data from hosted Supabase

Do not commit connection strings or passwords.

## Option A: Supabase CLI (recommended)

```powershell
# Install: npm i -g supabase
cd baller_app
supabase login
supabase link --project-ref <your-project-ref>

# Schema + data dump (customize -t for tables only)
supabase db dump -f ../../backend/scripts/supabase-export.sql
```

## Option B: pg_dump with direct connection

1. Supabase Dashboard → Project Settings → Database → Connection string (URI, session mode).
2. Run from a machine with PostgreSQL client tools:

```powershell
$env:PGPASSWORD = "<password>"
pg_dump "postgresql://postgres.<ref>:<password>@aws-0-eu-central-1.pooler.supabase.com:5432/postgres" `
  --schema=public `
  --table=public.courts `
  --table=public.profiles `
  --table=public.court_images `
  --data-only `
  -f backend/scripts/supabase-data.sql
```

## Tables to migrate

| Table | Notes |
|-------|--------|
| `courts` | Include all rows; map `status` if column exists |
| `profiles` | `id` must match future `users.id` on full auth cutover |
| `court_images` | FK to `courts.id` |

## Auth users

Supabase `auth.users` password hashes **cannot** be imported into Argon2 `users` table. Plan:

1. Import `profiles` with existing UUIDs.
2. On cutover, users run **password reset** via new API, or
3. Hybrid period: keep Supabase Auth until all users migrated.

## Validation after import

```sql
SELECT 'courts' AS t, COUNT(*) FROM courts
UNION ALL SELECT 'profiles', COUNT(*) FROM profiles
UNION ALL SELECT 'court_images', COUNT(*) FROM court_images;
```

Compare counts with Supabase Dashboard table editor.
