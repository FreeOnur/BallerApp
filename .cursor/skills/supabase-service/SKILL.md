---
name: supabase-service
description: Creates new Supabase service files in `baller_app/lib/supabase/` using the same structure as `court_services.dart` (client setup, query chaining, typed returns, and exception wrapping). Use when users say 'add service', 'new query', 'supabase function', 'database call', or when editing/adding files under `baller_app/lib/supabase/`. Capabilities include generating service class boilerplate, mapping query results to typed Dart models, and adding project-matching validation commands. Do NOT use for Supabase Edge Functions, SQL migrations, or auth UI flows.
---
# Supabase Service

## Critical

- Always create service files under `baller_app/lib/supabase/` and use snake_case with `_services.dart` suffix (example: `court_services.dart`).
- Service classes must use `package:supabase_flutter/supabase_flutter.dart` and initialize the client as a field: `final SupabaseClient _supabase = Supabase.instance.client;`.
- Keep method return types explicit and typed (`Future<String>`, `Future<void>`, `Future<List<Court>>`, etc.). Do not return untyped `dynamic`.
- If a query can fail, wrap the DB call in `try/catch` and rethrow `Exception('Failed to <action>: $e')`, matching existing error style in `lib/auth/auth_service.dart` and `lib/pages/Home/home_page.dart`.
- For single-row inserts/selects that must return one object, use `.select(...).single()` and cast fields explicitly (example in `lib/supabase/court_services.dart`: `return res['id'] as String;`).

## Instructions

1. Identify the target table, return type, and required inputs from the user request.
   - Read `baller_app/lib/supabase/court_services.dart` and mirror its structure: one service class, one public async method per query operation, explicit `required` named parameters.
   - If the method should return a model, confirm whether a model exists in `baller_app/lib/models/` (example: `Court.dart` with `Court.fromMap`).
   - This step has no dependencies.
   - Verify you have: table name, method name, and final return type before proceeding to the next step.

2. Create or update the service file with project-matching boilerplate.
   - File path pattern: `baller_app/lib/supabase/<entity>_services.dart`.
   - Start with:
     - `import 'package:supabase_flutter/supabase_flutter.dart';`
     - If returning models, also import with project package style (for Court: `import 'package:baller_app/models/Court.dart';`).
   - Create class name using PascalCase + `Services` suffix (example: `CourtServices`).
   - Add the class field exactly: `final SupabaseClient _supabase = Supabase.instance.client;`.
   - This step uses the output from Step 1.
   - Verify class name, file name, and imports match project conventions before proceeding to the next step.

3. Implement the Supabase query method using existing chain style.
   - Use `_supabase.from('<table>')` for consistency (even though `court_services.dart` currently calls `Supabase.instance.client` directly inside the method).
   - Match existing key mapping style from `createCourt`:
     - Build an insert/update map inline.
     - Chain `.select('<fields>')` when returning data.
     - Use `.single()` when exactly one row is expected.
   - Keep parameters named and explicit (`required` where needed), matching `createCourt` style.
   - This step uses the output from Step 2.
   - Verify every map key matches the DB column names used elsewhere (examples: `has_markings`, `surface`, `status`) before proceeding to the next step.

4. Add typed result mapping and error handling.
   - For scalar return values:
     - Cast directly (example: `return res['id'] as String;`).
   - For model lists:
     - Cast response to list and map through `fromMap` (pattern from `MapPage.fetchCourts`: `final data = res as List;` then `data.map((e) => Court.fromMap(e)).toList();`).
   - For operations that can fail, wrap query in:
     - `try { ... } catch (e) { throw Exception('Failed to <action>: $e'); }`
   - Keep exception message format consistent with:
     - `Failed to create profile: $e`
     - `Error fetching username: $e`
   - This step uses the output from Step 3.
   - Verify all returns are strongly typed and no method returns `dynamic` before proceeding to the next step.

5. Validate formatting and static analysis before finishing.
   - From `baller_app/`, run:
     - `dart format lib/supabase/<file_name>.dart`
     - `flutter analyze lib/supabase/<file_name>.dart`
   - If you added/used a model mapping, also run:
     - `flutter analyze lib/models/<ModelFile>.dart`
   - This step uses the output from Step 4.
   - Verify both commands pass with no new analyzer errors before proceeding to the next step.

6. Confirm call-site compatibility when replacing inline queries.
   - If this service replaces inline query code (for example in `lib/pages/Map/map_page.dart`), ensure the caller expects the same type and shape as before.
   - Keep existing UI/state logic unchanged; only move query logic into the new service.
   - This step uses the output from Step 5.
   - Verify the caller still receives the same data type (`String`, `List<Court>`, etc.) before proceeding to completion.

## Examples

User says: "Add a new query service to fetch approved courts for the map."

Actions taken:
1. Read `baller_app/lib/supabase/court_services.dart` and `baller_app/lib/models/Court.dart`.
2. Update `baller_app/lib/supabase/court_services.dart` by adding:
   - `Future<List<Court>> getApprovedCourts()`
   - Query chain: `_supabase.from('courts').select().eq('status', 'approved')`
   - Mapping: `final data = res as List; return data.map((e) => Court.fromMap(e)).toList();`
   - Error handling: `try/catch` with `throw Exception('Failed to fetch approved courts: $e');`
3. Run `dart format lib/supabase/court_services.dart`.
4. Run `flutter analyze lib/supabase/court_services.dart lib/models/Court.dart`.

Result:
- A typed Supabase method exists in the service layer, follows the current `CourtServices` pattern, and can replace inline query logic in `MapPage.fetchCourts()` without changing UI behavior.

## Common Issues

- If you see `PostgrestException: relation "<table>" does not exist`:
  1. Verify the table name in `.from('<table>')` matches the actual table (example uses `courts`).
  2. Check column names in the map (`has_markings`, `surface`, `lights`) for typos.
  3. Re-run `flutter analyze lib/supabase/<file_name>.dart` after fixing.

- If you see `type 'Null' is not a subtype of type 'String'` on `res['id'] as String`:
  1. Verify your query includes `.select('id')` before `.single()`.
  2. Confirm the insert/select actually returns `id` (not filtered out by selected fields).
  3. If nullable by design, change return type to `Future<String?>` and cast accordingly.

- If you see `PostgrestException: JSON object requested, multiple (or no) rows returned` when using `.single()`:
  1. Ensure the filter uniquely identifies one row.
  2. If multiple rows are valid, replace `.single()` with list handling and return `Future<List<...>>`.
  3. If zero rows are valid, use nullable return handling instead of forced single-row semantics.

- If you see `Exception: No user logged in` (or `No user logged in!`) in service logic:
  1. Check `final user = _supabase.auth.currentUser;` before DB writes tied to a profile.
  2. Guard with null check and throw a clear exception before querying.
  3. Ensure caller runs only after auth is established.

- If analyzer reports import/path issues for models:
  1. Use the existing package import style from this project, e.g. `import 'package:baller_app/models/Court.dart';`.
  2. Verify the file name casing matches the actual file in `lib/models/`.
  3. Run `flutter analyze lib/supabase/<file_name>.dart lib/models/<ModelFile>.dart` again.