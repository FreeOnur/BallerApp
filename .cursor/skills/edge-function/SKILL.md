---
name: edge-function
description: Creates Supabase Edge Functions in `baller_app/supabase/functions/` by replicating the `get-upload-url` structure, Deno handler shape, JSON request/response contract, and `deno.json` configuration. Use when users say "add edge function", "serverless function", "create API endpoint", or ask to add files under `baller_app/supabase/functions/`. Capabilities include scaffolding files, wiring imports/env usage, consistent error handling, and local verification commands. Do NOT use for Flutter/Dart client code, UI work, or changes under `baller_app/lib/`.
---
# Edge Function

## Critical

- Always clone the implementation pattern from `baller_app/supabase/functions/get-upload-url/` before adding new logic. Do not invent a different runtime style.
- Keep function names in kebab-case and folder names identical to the deployed function name: `baller_app/supabase/functions/<function-name>/`.
- Maintain JSON-only API behavior (JSON request parsing, JSON response bodies, explicit status codes) matching `get-upload-url`.
- Do not place edge-function logic in Flutter code (`baller_app/lib/**`).
- Before writing business logic, verify `index.ts` and `deno.json` both exist for the new function.

## Instructions

1. Identify and lock the source pattern
   - Use `baller_app/supabase/functions/get-upload-url/index.ts` and `baller_app/supabase/functions/get-upload-url/deno.json` as the canonical template.
   - Extract these exact elements from `get-upload-url/index.ts` and reuse them in the new function:
     - import block
     - `serve(...)` handler shape
     - request method handling pattern
     - JSON parse + validation flow
     - success/error response format and headers
   - Verify the template files exist and are readable before proceeding to the next step.
   - This step produces the baseline structure used in Step 2.

2. Create the function directory and base files
   - Create: `baller_app/supabase/functions/<function-name>/`.
   - Add `index.ts` by copying `baller_app/supabase/functions/get-upload-url/index.ts`, then rename internal identifiers/messages for the new capability.
   - Add `deno.json` by copying `baller_app/supabase/functions/get-upload-url/deno.json` and only changing entries that must reference the new file/function.
   - Keep naming conventions consistent:
     - folder: kebab-case
     - any exported/internal function names: same style used in `get-upload-url/index.ts`
   - Verify both files were created and that `index.ts` still contains the same top-level handler pattern as the template before proceeding to the next step.
   - This step uses the baseline structure from Step 1.

3. Implement request contract and method guards
   - In `baller_app/supabase/functions/<function-name>/index.ts`, preserve the same request contract pattern as `get-upload-url`:
     - enforce HTTP method(s) with the same conditional style
     - parse request body with the same JSON parsing approach
     - validate required fields before side effects
   - Reuse the same response envelope style as the template (keys, status code mapping, and header behavior).
   - If adding new request fields, validate each field explicitly before use.
   - Verify every non-happy-path exits with the same structured JSON error pattern before proceeding to the next step.
   - This step uses files created in Step 2.

4. Implement business logic with existing Supabase env conventions
   - Reuse the same environment access approach used by `get-upload-url` (for example, reading keys/URLs from `Deno.env` exactly how the template does it).
   - Keep external clients/utilities initialization in the same location/scope pattern as `get-upload-url` unless the template already does per-request initialization.
   - Wrap side-effect operations (storage/database/network calls) in `try/catch` using the same error mapping style as the template.
   - Return deterministic JSON for success and failure; do not return raw thrown errors.
   - Verify no secret values are logged and all thrown exceptions are converted to JSON responses before proceeding to the next step.
   - This step uses the request-validation flow from Step 3.

5. Align `deno.json` and import stability
   - Ensure `baller_app/supabase/functions/<function-name>/deno.json` mirrors the `get-upload-url` structure for:
     - compiler/lint settings
     - import map structure (if present)
     - tasks (if present)
   - Keep Deno import URLs and version pins consistent with `get-upload-url`; do not introduce new versions unless required by new dependencies.
   - Verify `deno.json` references are valid for `index.ts` and there are no missing import-map entries before proceeding to the next step.
   - This step uses `index.ts` from Step 4.

6. Run local validation gates
   - From repo root or `baller_app/`, run the same validation style used for Supabase functions in this project:
     - `deno fmt baller_app/supabase/functions/<function-name>/index.ts`
     - `deno check baller_app/supabase/functions/<function-name>/index.ts`
   - If Supabase CLI is available, run a local serve/invoke loop from `baller_app/`:
     - `supabase functions serve <function-name>`
     - invoke with JSON payload and verify response shape matches template conventions.
   - Verify formatting, type checking, and at least one successful JSON response before proceeding to the next step.
   - This step uses code/config from Steps 2-5.

7. Final consistency review against `get-upload-url`
   - Compare new function and template side-by-side:
     - same handler scaffolding
     - same error serialization strategy
     - same header handling approach
     - same `deno.json` schema shape
   - Confirm folder/file naming follows `baller_app/supabase/functions/<function-name>/{index.ts,deno.json}` exactly.
   - Verify no Dart files under `baller_app/lib/**` were changed for this task before considering work complete.
   - This step uses outputs from all previous steps.

## Examples

### Example 1
User says: "Add edge function `create-checkout-session` under `baller_app/supabase/functions/`."

Actions taken:
1. Read `baller_app/supabase/functions/get-upload-url/index.ts` and `baller_app/supabase/functions/get-upload-url/deno.json`.
2. Create `baller_app/supabase/functions/create-checkout-session/index.ts` by copying template handler structure.
3. Keep the same import and `serve` wrapper pattern, then replace request fields with checkout-specific fields.
4. Keep JSON success/error response envelope style identical to template.
5. Copy and align `deno.json` from template.
6. Run:
   - `deno fmt baller_app/supabase/functions/create-checkout-session/index.ts`
   - `deno check baller_app/supabase/functions/create-checkout-session/index.ts`

Result:
- New function matches existing project edge-function conventions and is ready for local Supabase serve/invoke testing.

## Common Issues

- `error: Uncaught (in promise) SyntaxError: Unexpected end of JSON input`
  1. Ensure request body parsing is guarded exactly like `get-upload-url`.
  2. Return a structured JSON 400 response when body is empty/invalid.
  3. Re-test with a valid `Content-Type: application/json` payload.

- `Function not found` when invoking locally
  1. Verify folder name equals function name: `baller_app/supabase/functions/<function-name>/`.
  2. Verify `index.ts` exists directly inside that folder.
  3. Restart local function serve command after creating new function.

- `Permission denied` or storage/database auth failures inside function
  1. Verify env keys are read using the same `Deno.env` pattern as `get-upload-url`.
  2. Confirm required env vars are available to local serve/deploy environment.
  3. Ensure the function is using the correct key/client for the intended operation.

- `Cannot resolve module` / import-map errors
  1. Compare `deno.json` with `baller_app/supabase/functions/get-upload-url/deno.json`.
  2. Ensure import-map entries and version pins are consistent.
  3. Run `deno check baller_app/supabase/functions/<function-name>/index.ts` again after fixing paths.

- CORS or browser fetch failures (for web callers)
  1. Reuse the same response/header pattern from `get-upload-url` for error and success responses.
  2. Ensure method guard handles preflight/options exactly as the template does (if present).
  3. Re-test from browser/client after header alignment.