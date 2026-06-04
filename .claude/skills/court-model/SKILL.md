---
name: court-model
description: Extends `Court.dart` with `factory fromMap`, snake_case DB keys aligned to `court_repository.dart`, `001_initial.sql`, and `/courts` responses. Use when the user says 'extend Court', 'add model field', 'Court.fromMap', or edits `baller_app/lib/models/`. Cross-check `court_services.dart` insert keys and both read paths (Supabase `.select()` + FastAPI `GET /courts`). Do NOT use for new API routes (`fastapi-router` skill), widgets-only UI work, auth changes, or repository refactors without model changes.
paths:
  - baller_app/lib/models/**
---
# Court Model

## Critical

- Model files live in `baller_app/lib/models/` with **PascalCase filenames** matching the class (`Court.dart` → `class Court`).
- **Canonical factory only:** `factory Court.fromMap(Map<String, dynamic> map)`. Do **not** add `fromJson`/`toJson` unless the user requests a project-wide serialization migration.
- **Map keys are snake_case** everywhere data enters the app — PostgREST, FastAPI `SELECT *`, and repository payloads all use DB column names (`has_markings`, `lights`, `surface`). **Dart fields are camelCase** (`hasMarkings`, `lights`, `surface`). Never read `map['hasMarkings']` or `map['groundType']` — those are repository param names, not map keys.
- **Single source of truth for columns:** `backend/migrations/001_initial.sql` → `courts` table. Both read paths return the same snake_case keys whether `AppConfig.useLegacySupabase` is true or false.
- Before finishing, cross-check every `fromMap` key against:
  1. `CREATE TABLE courts` in `backend/migrations/001_initial.sql`
  2. `CourtRepository.createCourt` insert map in `baller_app/lib/repositories/court_repository.dart`
  3. `GET /courts` response shape in `backend/app/routers/courts.py` (`SELECT * FROM courts WHERE status = 'approved'`)
  4. Legacy insert keys in `baller_app/lib/supabase/court_services.dart` (delegates to repository — do not duplicate maps there)
- Model files have **no imports** (plain Dart class). Do not add `supabase_flutter`, `dio`, or Flutter imports to model files.
- Package imports at call sites: `import 'package:baller_app/models/Court.dart';` (package name from `baller_app/pubspec.yaml` → `name: baller_app`).
- Do **not** change widgets, auth, backend routers, or Edge Functions in this skill's scope.
- Lint: `baller_app/analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`.

### Current `Court` shape (baseline)

```dart
class Court {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final bool indoor;

  Court({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.indoor,
  });

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: map['id'] as String,
      name: map['name'] ?? '',
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      indoor: map['indoor'] ?? false,
    );
  }
}
```

### `courts` column ↔ Dart mapping

| DB key (`map['…']`) | Repository param (Dart) | Suggested Dart field | `fromMap` pattern |
|---------------------|---------------------------|----------------------|-------------------|
| `id` | returned from create | `String id` | `map['id'] as String` |
| `name` | `name` | `String name` | `map['name'] ?? ''` |
| `lat` | `latitude` | `double lat` | `(map['lat'] as num).toDouble()` |
| `lng` | `longitude` | `double lng` | `(map['lng'] as num).toDouble()` |
| `indoor` | `indoor` | `bool indoor` | `map['indoor'] ?? false` |
| `lights` | `hasLights` | `bool lights` | `map['lights'] ?? false` |
| `has_markings` | `hasCourtMarkings` | `bool hasMarkings` | `map['has_markings'] ?? false` |
| `surface` | `groundType` | `String? surface` | `map['surface'] as String?` |
| `hoops` | `hoops` | `int? hoops` | `map['hoops'] == null ? null : (map['hoops'] as num).toInt()` |
| `address` | `address` | `String? address` | `map['address'] as String?` |
| `source` | hardcoded `'community'` in create | omit unless UI reads it | — |
| `status` | filtered on read, not in create body | omit from model | reads filter `status = 'approved'` |
| `created_at` | not in create | omit unless UI reads it | — |

**Gap today:** `createCourt` persists `lights`, `has_markings`, `surface`, `hoops`, `address` but baseline `fromMap` only maps `id`, `name`, `lat`, `lng`, `indoor`. Extending the model is expected when UI needs those fields.

### Data flow (both auth modes)

```
fetchApprovedCourts() → List<Map<String,dynamic>> → Court.fromMap(e) → List<Court>
  legacy:  Supabase .from('courts').select().eq('status','approved')
  API:     ApiClient.dio.get('/courts')  // courts router SELECT *
```

## Instructions

1. **Inventory persisted fields from schema and repository**
   - Read `backend/migrations/001_initial.sql` → `CREATE TABLE courts (...)`.
   - Read `baller_app/lib/repositories/court_repository.dart` → `createCourt` body keys and `fetchApprovedCourts` return type.
   - Confirm FastAPI list shape: `backend/app/routers/courts.py` → `list_approved_courts()` does `SELECT * FROM courts WHERE status = 'approved'`.
   - Cross-check insert keys in `baller_app/lib/supabase/court_services.dart` (must match repository, not diverge).
   - Grep consumers: `grep -r "Court\." baller_app/lib --include="*.dart"` (primary: `baller_app/lib/pages/Map/`, court detail pages).
   - **Verify:** written list of DB keys and intended Dart field names before Step 2.

2. **Scaffold or extend model under `baller_app/lib/models/`**
   - Mirror baseline shape (no imports):

```dart
class Court {
  final String id;
  final String name;
  // add new finals here

  Court({
    required this.id,
    required this.name,
  });

  factory Court.fromMap(Map<String, dynamic> map) { ... }
}
```

   - Use `final` for all stored fields; `required` in constructor for non-nullable fields.
   - **Verify:** class name `Court`, every new field in constructor and `fromMap`.
   - **Uses output from Step 1.**

3. **Implement `fromMap` with project cast style**
   - Copy patterns from baseline `Court.fromMap` above.
   - Required strings: `map['id'] as String`, `map['name'] ?? ''`.
   - Required doubles: `(map['lat'] as num).toDouble()`.
   - Booleans with DB defaults: `map['indoor'] ?? false`, `map['lights'] ?? false`, `map['has_markings'] ?? false`.
   - Nullable columns: `surface: map['surface'] as String?`; `hoops: map['hoops'] == null ? null : (map['hoops'] as num).toInt()`.
   - **Verify:** every `map['key']` uses DB snake_case; mental diff against `001_initial.sql` columns.
   - **Uses output from Step 2.**

4. **Align repository param names vs map keys (do not conflate)**
   - Court repository Dart params (`hasLights`, `hasCourtMarkings`, `groundType`, `latitude`, `longitude`) write DB keys (`lights`, `has_markings`, `surface`, `lat`, `lng`) in both legacy Supabase and API POST body.
   - `baller_app/lib/supabase/court_services.dart` delegates to `RepositoryProvider.courts` — do not duplicate insert maps there.
   - Model reads **DB keys only** in `fromMap`. If adding a new persisted field, update `court_repository.dart` and `backend/app/routers/courts.py` `CreateCourtRequest` + INSERT in the same task if requested.
   - **Verify:** each create key that should round-trip on read has a matching `fromMap` line.
   - **Uses output from Step 3.**

5. **Preserve call-site compatibility**
   - Keep mapping in `baller_app/lib/pages/Map/`:
     - `courts = data.map((e) => Court.fromMap(e)).toList();`
   - If analyzer complains about `dynamic` elements:
     - `data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();`
   - `fetchCourts()` calls `RepositoryProvider.courts.fetchApprovedCourts()` — do not switch to direct Supabase in pages.
   - **Verify:** `grep -r "Court\." baller_app/lib` — new non-nullable fields must not break existing uses (`court.name`, `court.lat`, `court.lng`, `court.id`).
   - **Uses output from Step 3.**

6. **Format and analyze**

```bash
cd baller_app && dart format lib/models/
cd baller_app && flutter analyze lib/models lib/repositories lib/pages/Map
```

   - **Verify:** zero analyzer errors in touched paths before completing.
   - **Uses output from Steps 2–5.**

## Examples

### Example: Map metadata fields already persisted by create

**User says:** "Add `lights`, markings, surface, hoops, and address to the Court model."

**Actions taken:**
1. Read `backend/migrations/001_initial.sql` and `baller_app/lib/repositories/court_repository.dart` — confirm keys: `lights`, `has_markings`, `surface`, `hoops`, `address`.
2. Add `final` fields to `baller_app/lib/models/Court.dart` (nullable where SQL allows NULL).
3. Extend `fromMap`:

```dart
factory Court.fromMap(Map<String, dynamic> map) {
  return Court(
    id: map['id'] as String,
    name: map['name'] ?? '',
    lat: (map['lat'] as num).toDouble(),
    lng: (map['lng'] as num).toDouble(),
    indoor: map['indoor'] ?? false,
    lights: map['lights'] ?? false,
    hasMarkings: map['has_markings'] ?? false,
    surface: map['surface'] as String?,
    hoops: map['hoops'] == null ? null : (map['hoops'] as num).toInt(),
    address: map['address'] as String?,
  );
}
```

4. Leave map page as `Court.fromMap(e)` — no repository changes needed.
5. Run `cd baller_app && flutter analyze lib/models lib/pages/Map`.

**Result:** `Court` round-trips rows from both Supabase `.select()` and FastAPI `GET /courts`; map list loading unchanged.

### Example: New entity model for court images

**User says:** "Add a CourtPhoto model."

**Actions taken:**
1. Read `backend/migrations/001_initial.sql` → `court_images(id, court_id, file_path, created_at)`.
2. Create `baller_app/lib/models/CourtPhoto.dart`:

```dart
class CourtPhoto {
  final String id;
  final String courtId;
  final String filePath;

  CourtPhoto({required this.id, required this.courtId, required this.filePath});

  factory CourtPhoto.fromMap(Map<String, dynamic> map) {
    return CourtPhoto(
      id: map['id'] as String,
      courtId: map['court_id'] as String,
      filePath: map['file_path'] as String,
    );
  }
}
```

3. Import where needed: `import 'package:baller_app/models/CourtPhoto.dart';`
4. Run `cd baller_app && flutter analyze lib/models/`.

**Result:** New entity follows the same `fromMap` + snake_case conventions as `Court`.

## Common Issues

- **`type 'Null' is not a subtype of type 'String' in type cast`** on `map['id'] as String`:
  1. Row missing `id` — ensure `fetchApprovedCourts` returns full rows (`.select()` or `SELECT *`).
  2. FastAPI may return UUID objects — if cast fails, use `map['id'].toString()`.
  3. Re-run `cd baller_app && flutter analyze lib/models/`.

- **`type 'Null' is not a subtype of type 'num' in type cast`** on `(map['lat'] as num).toDouble()`:
  1. Column is null in DB — change field to `double?` and use `map['lat'] == null ? null : (map['lat'] as num).toDouble()`.
  2. Confirm map UI handles null before marker placement.

- **Field always null at runtime but create sends a value:**
  1. Wrong map key — e.g. `map['hasMarkings']` instead of `map['has_markings']`.
  2. Fix `fromMap` to match repository create keys (`lights`, not `hasLights`).

- **`The argument type 'List<dynamic>' can't be assigned to the parameter type 'List<Court>'`:**
  1. In map pages: `data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();`
  2. Run `cd baller_app && flutter analyze lib/pages/Map/`.

- **`Undefined name 'Court'`:**
  1. Add `import 'package:baller_app/models/Court.dart';` (not relative `../models/`).
  2. Match filename casing to class name.

- **New field works in legacy mode but not API mode (or vice versa):**
  1. Compare keys in both branches of `baller_app/lib/repositories/court_repository.dart` — they must match.
  2. Confirm `backend/app/routers/courts.py` `CreateCourtRequest` and INSERT include the column.
  3. If column missing from SQL, add migration under `backend/migrations/` (`postgres-migrations` skill) before mapping in Dart.

- **Analyzer: "All final variables must be initialized" after adding fields:**
  1. Add field to constructor with `required` (non-nullable) or default value.
  2. Assign it inside `fromMap`.

- **`.cursor/rules/flutter-conventions.mdc` mentions `fromJson` but Court does not:**
  1. For `Court` and sibling models, follow **`fromMap` only** unless user requests repo-wide migration.
  2. Do not add `toJson` for symmetry with the rules file alone.