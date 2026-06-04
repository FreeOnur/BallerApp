---
paths:
  - baller_app/lib/supabase/**
  - baller_app/supabase/**
---

# Supabase Services & Edge Functions

## Client (`baller_app/lib/supabase/`)

- Class field: `final SupabaseClient _supabase = Supabase.instance.client;`
- `court_services.dart` → delegates to `RepositoryProvider.courts` for dual-mode court CRUD
- Inserts: `.insert({...}).select('id').single()` → `return res['id'] as String;`
- Failures: `try/catch` → `throw Exception('Failed to <action>: $e')` (match `auth_service.dart`)

## Edge (`baller_app/supabase/functions/`)

- Template: `get-upload-url/index.ts` + `deno.json`
- Config: `baller_app/supabase/config.toml` → `[functions.get-upload-url]` (`verify_jwt = true`)
- B2 creds: `Deno.env.get("B2_KEY_ID")` / `Deno.env.get("B2_APP_KEY")` only
- JSON response: `{ uploadURL, filePath }` or `{ error }` with status 500
- Local: `supabase functions serve get-upload-url --no-verify-jwt`
- Deno VS Code: `baller_app/.vscode/settings.json` → `deno.enablePaths: ["supabase/functions"]`
