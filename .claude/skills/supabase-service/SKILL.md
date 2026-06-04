---
name: supabase-service
description: Creates and extends Supabase client service classes in `baller_app/lib/supabase/` mirroring `CourtServices` in `court_services.dart` (client field, PostgREST query chaining, typed returns, snake_case column maps, exception wrapping). Use when the user says 'add service', 'new query', 'database call', 'supabase query', or edits files under `lib/supabase/`. Key capabilities: scaffold `<entity>_services.dart`, map rows to models via `fromMap`, auth-guarded writes, and validate with `flutter analyze`. Do NOT use for Edge Functions (`baller_app/supabase/functions/`), SQL migrations, storage upload flows in widgets, or auth UI (`lib/auth/`, login/register pages).
paths:
  - baller_app/lib/supabase/**/*.dart
---
# Supabase Service

## Critical

- Service files live in `baller_app/lib/supabase/` with **snake_case** names and `_services.dart` suffix (example: `court_services.dart` → `class CourtServices`).
- Import only `package:supabase_flutter/supabase_flutter.dart` unless returning a model — then add `import 'package:baller_app/models/<Model>.dart';` (example: `Court.dart`).
- Every service class must declare: `final SupabaseClient _supabase = Supabase.instance.client;`
- **Use `_supabase` inside methods**, not `Supabase.instance.client` directly. (`court_services.dart` currently mixes both; new code must use `_supabase`.)
- Supabase is initialized in `baller_app/lib/main.dart` via `Supabase.initialize(...)` before `AuthGate()`. Services assume the client is ready — do not call `Supabase.initialize` from services.
- DB map keys are **snake_case** exactly as PostgREST expects (`has_markings`, `lights`, `surface`, `skill_level`). Dart method params may be camelCase; translate in the insert/update map.
- Return types must be explicit: `Future<String>`, `Future<void>`, `Future<List<Court>>`, `Future<Map<String, dynamic>?>`, etc. Never return untyped `dynamic`.
- Wrap fallible queries in `try/catch` and rethrow `Exception('Failed to <action>: $e')` (match `auth_service.dart` `createProfile` and `home_page.dart` `getUserName`).
- For user-scoped writes, guard first:
  ```dart
  final user = _supabase.auth.currentUser;
  if (user == null) throw Exception('No user logged in!');
  ```
  (`auth_service.dart` uses `'No user logged in!'`; `home_page.dart` uses `'No user logged in'` — pick one per file and stay consistent within that file.)
- Do **not** put Supabase queries in widgets when extracting to a service. Call sites instantiate the service (see `create_map_window.dart`: `final courtServices = CourtServices();`).

### Canonical reference: `CourtServices.createCourt`

From `baller_app/lib/supabase/court_services.dart`:

| Dart param | DB key in insert map |
|------------|----------------------|
| `name` | `name` |
| `latitude` | `lat` |
| `longitude` | `lng` |
| `indoor` | `indoor` |
| `hasLights` | `lights` |
| `hasCourtMarkings` | `has_markings` |
| `groundType` | `surface` |
| `hoops` | `hoops` |
| `address` | `address` |
| (hardcoded) | `source: 'community'` |

Insert chain: `.from('courts').insert({...}).select('id').single()` → `return res['id'] as String;`

Read pattern (currently inline in `map_page.dart`, target for extraction): `.from('courts').select().eq('status', 'approved')` → `final data = res as List;` → `data.map((e) => Court.fromMap(e)).toList();`

## Instructions

1. **Gather table, operation, and return type**
   - Read `baller_app/lib/supabase/court_services.dart` for the canonical service shape.
   - If the query already exists inline, grep for it:
     ```bash
     cd baller_app && grep -r "\.from('" lib/
     ```
   - Common tables in this repo: `courts`, `profiles`, `court_images`.
   - Decide: insert / select list / select single / update / upsert / delete.
   - **Verify:** you have table name, method name, and explicit `Future<...>` return type before Step 2.

2. **Create or open the service file**
   - New entity → `baller_app/lib/supabase/<entity>_services.dart`.
   - Same table → add methods to the existing class (e.g. add `getApprovedCourts` to `CourtServices`).
   - Boilerplate:
     ```dart
     import 'package:supabase_flutter/supabase_flutter.dart';
     // import 'package:baller_app/models/Court.dart'; // when returning models

     class CourtServices {
       final SupabaseClient _supabase = Supabase.instance.client;

       // methods here
     }
     ```
   - Class name: PascalCase entity + `Services` (`ProfileServices`, `CourtServices`).
   - **Verify:** filename is snake_case, class name is PascalCase, import path uses package `baller_app` for models.
   - **Uses output from Step 1.**

3. **Implement the query method with project chain style**
   - **Insert returning ID** (mirror `createCourt`):
     ```dart
     Future<String> createCourt({ required String name, ... }) async {
       try {
         final res = await _supabase
             .from('courts')
             .insert({
               'source': 'community',
               'name': name,
               'lat': latitude,
               'lng': longitude,
               'indoor': indoor,
               'lights': hasLights,
               'has_markings': hasCourtMarkings,
               'surface': groundType,
               'hoops': hoops,
               'address': address,
             })
             .select('id')
             .single();
         return res['id'] as String;
       } catch (e) {
         throw Exception('Failed to create court: $e');
       }
     }
     ```
   - **Select list returning models** (mirror `map_page.dart` `fetchCourts`):
     ```dart
     Future<List<Court>> getApprovedCourts() async {
       try {
         final res = await _supabase
             .from('courts')
             .select()
             .eq('status', 'approved');
         final data = res as List;
         return data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();
       } catch (e) {
         throw Exception('Failed to fetch approved courts: $e');
       }
     }
     ```
   - **Select single row** (mirror `home_page.dart` / `auth_gate.dart`):
     - Exactly one expected: `.select('username').eq('id', user.id).single()`
     - Zero or one expected: `.select().eq('id', user.id).maybeSingle()` → return `null` if absent
   - **Upsert** (mirror `auth_service.dart` `createProfile`):
     ```dart
     await _supabase.from('profiles').upsert({
       'id': user.id,
       'username': username,
       'skill_level': skillLevel,
     });
     ```
   - Use `required` named params for non-optional inputs, matching `createCourt` style.
   - **Verify:** every map key matches DB column names; `.single()` is only used when exactly one row is valid.
   - **Uses output from Step 2.**

4. **Add auth guards and typed casts**
   - Before writes tied to the logged-in user, read `_supabase.auth.currentUser` and throw if null.
   - Scalar cast: `return data['username'] as String;`
   - Nullable scalar: `return data['avatar_url'] as String?;`
   - Never cast list elements as `dynamic` when analyzer complains — use `e as Map<String, dynamic>` before `fromMap`.
   - **Verify:** no method returns `dynamic`; auth-guarded methods throw before querying when user is null.
   - **Uses output from Step 3.**

5. **Wire call sites (when replacing inline queries)**
   - Import: `import 'package:baller_app/supabase/court_services.dart';`
   - Instantiate once per widget/state class: `final courtServices = CourtServices();`
   - Replace inline `Supabase.instance.client.from(...)` with `await courtServices.<method>(...)`.
   - Keep UI validation (SnackBars, form checks) in the widget; keep DB logic in the service.
   - Example call site: `baller_app/lib/widgets/popups/create_map_window.dart` lines 59–69 call `courtServices.createCourt(...)` and use returned `courtId` for image upload.
   - **Verify:** caller still receives the same type (`String`, `List<Court>`, etc.) and behavior is unchanged.
   - **Uses output from Step 4.**

6. **Validate**
   - From `baller_app/`:
     ```bash
     dart format lib/supabase/<file>.dart
     flutter analyze lib/supabase/<file>.dart
     ```
   - If models are imported:
     ```bash
     flutter analyze lib/models/<Model>.dart lib/supabase/<file>.dart
     ```
   - If call sites changed:
     ```bash
     flutter analyze lib/supabase/<file>.dart lib/pages/Map lib/widgets/popups
     ```
   - **Verify:** zero new analyzer errors before completing.
   - **Uses output from Steps 2–5.**

## Examples

### Example A: Add read method to existing `CourtServices`

**User says:** "Move approved-courts fetch from the map page into the service."

**Actions taken:**
1. Read `baller_app/lib/pages/Map/map_page.dart` `fetchCourts()` — query: `.from('courts').select().eq('status', 'approved')`.
2. Read `baller_app/lib/models/Court.dart` — confirm `Court.fromMap` exists.
3. Add to `baller_app/lib/supabase/court_services.dart`:
   - `import 'package:baller_app/models/Court.dart';`
   - `Future<List<Court>> getApprovedCourts()` with `_supabase` chain, list cast, `fromMap`, and `try/catch`.
4. Update `map_page.dart`:
   - Add `import 'package:baller_app/supabase/court_services.dart';`
   - Replace inline query with `courts = await CourtServices().getApprovedCourts();`
5. Run `dart format lib/supabase/court_services.dart lib/pages/Map/map_page.dart`.
6. Run `flutter analyze lib/supabase/court_services.dart lib/models/Court.dart lib/pages/Map/map_page.dart`.

**Result:** Map loading behavior unchanged; query logic lives in `CourtServices` matching `createCourt` conventions.

### Example B: New `ProfileServices` read method

**User says:** "Add a service method to fetch the current user's username."

**Actions taken:**
1. Create `baller_app/lib/supabase/profile_services.dart` with `ProfileServices` class and `_supabase` field.
2. Implement `Future<String> getCurrentUsername()`:
   - Guard `currentUser`.
   - Query `_supabase.from('profiles').select('username').eq('id', user.id).single()`.
   - Return `data['username'] as String` inside `try/catch` → `Exception('Failed to fetch username: $e')`.
3. Refactor `baller_app/lib/pages/Home/home_page.dart` `getUserName()` to delegate to `ProfileServices().getCurrentUsername()`.
4. Run `flutter analyze lib/supabase/profile_services.dart lib/pages/Home/home_page.dart`.

**Result:** Username fetch follows `home_page.dart` error messages and `auth_service.dart` client-field pattern.

## Common Issues

- **`PostgrestException: relation "courts" does not exist`** (or any table name):
  1. Confirm `.from('courts')` spelling matches the Supabase table.
  2. Check insert/select map keys against `court_services.dart` (`has_markings`, not `hasMarkings`).
  3. Re-run `flutter analyze lib/supabase/<file>.dart`.

- **`type 'Null' is not a subtype of type 'String'`** on `res['id'] as String`:
  1. Ensure insert chain includes `.select('id')` before `.single()`.
  2. Confirm RLS allows the insert+select for the current role.
  3. If ID may be absent, change return type to `Future<String?>`.

- **`PostgrestException: JSON object requested, multiple (or no) rows returned`** with `.single()`:
  1. Tighten filters (`.eq('id', user.id)`) so only one row matches.
  2. If zero rows is valid, switch to `.maybeSingle()` and return nullable type.
  3. If many rows are valid, remove `.single()` and return `Future<List<...>>`.

- **`Exception: No user logged in!`** / **`No user logged in`** at runtime:
  1. Confirm `Supabase.initialize` ran in `main.dart` and session exists (`AuthGate` shows authenticated shell).
  2. Add `final user = _supabase.auth.currentUser; if (user == null) throw Exception('No user logged in!');` before user-scoped queries.
  3. Do not call write methods from unauthenticated routes.

- **`The argument type 'List<dynamic>' can't be assigned`** when mapping courts:
  1. Cast elements: `data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();`
  2. Re-run `flutter analyze lib/supabase/<file>.dart lib/models/Court.dart`.

- **Analyzer: `Undefined name 'Court'`**:
  1. Add `import 'package:baller_app/models/Court.dart';` (package name from `baller_app/pubspec.yaml`: `name: baller_app`).
  2. Match filename casing: `Court.dart`, not `court.dart`.

- **`PostgrestException: new row violates row-level security policy`**:
  1. Verify insert includes required columns (`source`, `status` defaults, or user-owned `id`).
  2. Test while authenticated if RLS requires `auth.uid()`.
  3. Do not disable RLS in client code — fix payload or policies separately.

- **Inconsistent client access** (`Supabase.instance.client` vs `_supabase`):
  1. In new/edited methods, always use `_supabase.from(...)`.
  2. When touching `createCourt`, prefer refactoring to `_supabase` in the same change set.