---
name: edge-function
description: Creates Supabase Edge Functions in `baller_app/supabase/functions/` by cloning `get-upload-url/index.ts`, `deno.json`, and wiring `[functions.<name>]` in `baller_app/supabase/config.toml`. Use when the user says "add edge function", "serverless API", "Backblaze/B2 upload API", or adds folders under `supabase/functions/`. Key capabilities: `Deno.serve` handler, JSON in/out, `Deno.env.get` secrets, `npm:` AWS SDK imports, local `supabase functions serve`. Do NOT use for Flutter/Dart (`baller_app/lib/**`), SQL migrations, or table CRUD in `court_services.dart` (use `supabase-service` / `court-model`).
paths:
  - baller_app/supabase/functions/**
  - baller_app/supabase/functions/*/index.ts
  - baller_app/supabase/functions/*/deno.json
  - baller_app/supabase/config.toml
---
# Edge Function

## Critical

- **Canonical template:** `baller_app/supabase/functions/get-upload-url/index.ts` + `baller_app/supabase/functions/get-upload-url/deno.json`. Clone structure before adding logic.
- **Folder name = deploy name:** kebab-case directory `baller_app/supabase/functions/<function-name>/` with `index.ts` at that path (not nested deeper).
- **Handler:** `Deno.serve(async (req) => { ... })` with outer `try/catch` — not `serve` from a separate import.
- **Responses:** `JSON.stringify(...)` + `{ headers: { "Content-Type": "application/json" } }`. Errors: `{ error: (e as Error).message }` and `status: 500` (same as template).
- **Secrets:** read only via `Deno.env.get("...")` (B2 example: `B2_KEY_ID`, `B2_APP_KEY`). Never hardcode keys or log secret values. See `.cursor/rules/security.mdc`.
- **Config required:** every new function needs a matching `[functions.<function-name>]` block in `baller_app/supabase/config.toml` (copy `[functions.get-upload-url]`).
- **Scope:** do not implement edge logic in `baller_app/lib/**`. Flutter invoke belongs in a separate task (`supabase-service` covers Dart services only).
- **Local JWT:** production block uses `verify_jwt = true`; local dev uses `supabase functions serve <name> --no-verify-jwt` per project docs.

## Instructions

1. **Read the template and confirm paths**
   - Open:
     - `baller_app/supabase/functions/get-upload-url/index.ts`
     - `baller_app/supabase/functions/get-upload-url/deno.json`
     - `baller_app/supabase/config.toml` → `[functions.get-upload-url]`
   - Lock these patterns from `index.ts`:
     - Top-of-file `npm:` imports and module-scoped client init (S3 example)
     - `Deno.serve(async (req) => { try { const body = await req.json(); ... } catch (e) { ... } })`
     - Success `new Response(JSON.stringify({ ... }), { headers: { "Content-Type": "application/json" } })`
     - Failure `new Response(JSON.stringify({ error: (e as Error).message }), { status: 500, headers: { "Content-Type": "application/json" } })`
   - `deno.json` in this repo is minimal: `{ "imports": {} }`.
   - **Verify:** all three paths exist and you can quote the handler shape before Step 2.
   - No prior step output.

2. **Create function directory and copy files**
   - Create `baller_app/supabase/functions/<function-name>/`.
   - Copy `index.ts` from `get-upload-url`, then replace business logic (keep `Deno.serve` + try/catch envelope).
   - Copy `deno.json` verbatim unless the new function needs extra `imports` entries:
     ```json
     {
       "imports": {}
     }
     ```
   - First line comment (optional, match template): `// supabase/functions/<function-name>/index.ts`
   - **Verify:** `ls baller_app/supabase/functions/<function-name>/` shows `index.ts` and `deno.json` before Step 3.
   - Uses Step 1 template.

3. **Wire `config.toml`**
   - In `baller_app/supabase/config.toml`, append (mirror `[functions.get-upload-url]`):
     ```toml
     [functions.<function-name>]
     enabled = true
     verify_jwt = true
     import_map = "./functions/<function-name>/deno.json"
     entrypoint = "./functions/<function-name>/index.ts"
     ```
   - Confirm `[edge_runtime]` exists (`enabled = true`, `deno_version = 2`) — do not duplicate that block.
   - **Verify:** `grep -n "\[functions.<function-name>\]" baller_app/supabase/config.toml` returns exactly one section with matching `import_map` and `entrypoint` paths before Step 4.
   - Uses folder name from Step 2.

4. **Implement JSON request contract**
   - Parse body the same way as template: `const { fieldA, fieldB } = await req.json();`
   - Validate required fields immediately after parse; on missing fields return:
     ```typescript
     return new Response(
       JSON.stringify({ error: "Missing required field: <name>" }),
       { status: 400, headers: { "Content-Type": "application/json" } }
     );
     ```
   - Template does not check HTTP method — only add `if (req.method !== "POST")` when the feature requires it.
   - **Verify:** every early exit returns JSON with `Content-Type: application/json` before Step 5.
   - Uses `index.ts` from Step 2.

5. **Implement side effects with env + module-level clients**
   - Reuse template env style:
     ```typescript
     accessKeyId: Deno.env.get("B2_KEY_ID")!,
     secretAccessKey: Deno.env.get("B2_APP_KEY")!,
     ```
   - Keep heavy clients (S3, fetch bases) at module scope like `get-upload-url`, not per request, unless state must be isolated.
   - For `npm:` deps, match import style:
     ```typescript
     import { S3Client, PutObjectCommand } from "npm:@aws-sdk/client-s3";
     import { getSignedUrl } from "npm:@aws-sdk/s3-request-presigner";
     ```
   - Wrap external calls inside the handler `try` block; let the outer `catch` map to `{ error: ... }` / 500.
   - **Verify:** no secret literals in source; all env names documented in function comment or PR notes before Step 6.
   - Uses validation from Step 4.

6. **Set local secrets and run Deno checks**
   - From `baller_app/` (Supabase project root):
     ```bash
     supabase secrets set B2_KEY_ID=<value> B2_APP_KEY=<value>
     ```
     (Add only env vars your function reads.)
   - Format and typecheck:
     ```bash
     deno fmt baller_app/supabase/functions/<function-name>/index.ts
     deno check baller_app/supabase/functions/<function-name>/index.ts
     ```
   - VS Code Deno is scoped in `baller_app/.vscode/settings.json` → `"deno.enablePaths": ["supabase/functions"]`.
   - **Verify:** `deno check` exits 0 before Step 7.
   - Uses `index.ts` / `deno.json` from Steps 2–5.

7. **Serve locally and smoke-test JSON**
   - From `baller_app/`:
     ```bash
     supabase functions serve <function-name> --no-verify-jwt
     ```
   - Invoke (upload-url contract example):
     ```bash
     curl -s -X POST "http://127.0.0.1:54321/functions/v1/<function-name>" \
       -H "Content-Type: application/json" \
       -d '{"filename":"court.jpg"}'
     ```
   - For `get-upload-url`, success shape is `{ "uploadURL": "...", "filePath": "originals/<timestamp>-<filename>" }`.
   - **Verify:** response is JSON, `Content-Type` is `application/json`, and error payloads use `{ "error": "..." }` before completion.
   - Uses config from Step 3 and code from Steps 4–6.

8. **Final review (no Flutter changes)**
   - Side-by-side compare new `index.ts` with `get-upload-url/index.ts`: same `Deno.serve` wrapper, same header pattern, same catch mapping.
   - Confirm `baller_app/lib/**` was not edited for this edge-function task.
   - Deploy when ready: `supabase functions deploy <function-name>` from `baller_app/`.
   - **Verify:** `[functions.<function-name>]` in `config.toml` matches folder name and `verify_jwt` intent (true for authenticated clients).
   - Uses all prior steps.

## Examples

### Example: Add `resize-court-image` edge function

**User says:** "Add a Supabase edge function `resize-court-image` that accepts a B2 `filePath` and returns a processing job id."

**Actions taken:**
1. Read `baller_app/supabase/functions/get-upload-url/index.ts` and `deno.json`.
2. Create `baller_app/supabase/functions/resize-court-image/index.ts` — keep:
   ```typescript
   Deno.serve(async (req) => {
     try {
       const { filePath } = await req.json();
       if (!filePath) {
         return new Response(
           JSON.stringify({ error: "Missing required field: filePath" }),
           { status: 400, headers: { "Content-Type": "application/json" } },
         );
       }
       // ... business logic ...
       return new Response(
         JSON.stringify({ jobId: "..." }),
         { headers: { "Content-Type": "application/json" } },
       );
     } catch (e) {
       const err = e as Error;
       return new Response(
         JSON.stringify({ error: err.message }),
         { status: 500, headers: { "Content-Type": "application/json" } },
       );
     }
   });
   ```
3. Copy `deno.json` (`{ "imports": {} }`) to `baller_app/supabase/functions/resize-court-image/deno.json`.
4. Add to `baller_app/supabase/config.toml`:
   ```toml
   [functions.resize-court-image]
   enabled = true
   verify_jwt = true
   import_map = "./functions/resize-court-image/deno.json"
   entrypoint = "./functions/resize-court-image/index.ts"
   ```
5. Run `deno fmt` + `deno check` on the new `index.ts`.
6. `supabase functions serve resize-court-image --no-verify-jwt` and POST JSON smoke test.

**Result:** Function folder, Deno config, and `config.toml` entry match `get-upload-url` conventions; ready for deploy and optional Dart `functions.invoke` in a follow-up.

## Common Issues

- **`SyntaxError: Unexpected end of JSON input` in function logs**
  1. Caller sent empty body; `await req.json()` throws (template has no guard).
  2. Fix caller to send `Content-Type: application/json` and a body, or add explicit empty-body check before `req.json()`.
  3. Re-test: `curl -X POST ... -d '{"filename":"x.jpg"}'`.

- **`Function not found` / 404 on `http://127.0.0.1:54321/functions/v1/<name>`**
  1. Folder must be `baller_app/supabase/functions/<name>/index.ts` (name matches URL segment).
  2. Confirm `[functions.<name>]` exists in `baller_app/supabase/config.toml` with correct `entrypoint`.
  3. Restart: `supabase functions serve <name> --no-verify-jwt`.

- **`401 Unauthorized` when `verify_jwt = true`**
  1. Expected in production config (`[functions.get-upload-url]` → `verify_jwt = true`).
  2. Local quick test: serve with `--no-verify-jwt`.
  3. With JWT enforced, pass `Authorization: Bearer <supabase_access_token>` from a signed-in user.

- **`error: Uncaught (in promise) ... credentials` / B2 signing fails**
  1. Confirm secrets: `supabase secrets list` includes `B2_KEY_ID` and `B2_APP_KEY`.
  2. Set via `supabase secrets set B2_KEY_ID=... B2_APP_KEY=...` from `baller_app/`.
  3. Match `Deno.env.get("B2_KEY_ID")` / `Deno.env.get("B2_APP_KEY")` spelling in `index.ts`.

- **`Cannot resolve module "npm:@aws-sdk/..."`**
  1. Use exact `npm:` prefix imports as in `get-upload-url/index.ts`.
  2. Ensure `import_map` in `config.toml` points to `./functions/<function-name>/deno.json`.
  3. Re-run `deno check baller_app/supabase/functions/<function-name>/index.ts`.

- **`Deno is not enabled` / no IntelliSense in VS Code**
  1. Open `baller_app/` workspace.
  2. Confirm `baller_app/.vscode/settings.json` contains `"deno.enablePaths": ["supabase/functions"]`.
  3. Install Deno VS Code extension (`denoland.vscode-deno`).

- **Wrong project root for Supabase CLI**
  1. Run `supabase` commands from `baller_app/` (where `supabase/config.toml` lives).
  2. Verify: `test -f baller_app/supabase/config.toml`.

- **Accidentally edited Flutter instead of edge fn**
  1. Revert changes under `baller_app/lib/**`.
  2. Edge functions live only under `baller_app/supabase/functions/`; Dart storage uploads in `create_map_window.dart` use `supabase.storage` — different path from B2 presign edge fn.