---
name: court-model
description: Scaffolds and extends Dart court models in `baller_app/lib/models/` using the `Court.dart` pattern (`final` fields, `fromMap`, snake_case Supabase keys). Use when the user says "add model", "map court row", "extend Court", or edits `Court.dart` / `court_services.dart`. Capabilities: field typing, `fromMap` casts, column alignment with `courts` insert/select keys (`lights`, `has_markings`, `surface`, etc.). Do NOT add `toJson`/`fromJson` unless the project adopts them everywhere; do NOT use for widgets, auth, Edge Functions, or service-only refactors with no model changes.
---
# Court Model

## Critical

- Model files live in `baller_app/lib/models/` with **PascalCase filenames** matching the class (`Court.dart` → `class Court`).
- **Canonical factory:** `factory Court.fromMap(Map<String, dynamic> map)` only. The app does **not** use `fromJson`/`toJson` on `Court` today — do not add them unless the user explicitly asks for a project-wide serialization migration.
- **Supabase map keys are snake_case** exactly as returned/inserted by PostgREST (`has_markings`, `lights`, `surface`). Dart fields stay **camelCase** (`hasMarkings`, `hasLights`, `groundType` only in service params — in `fromMap` read DB keys).
- Before finishing, cross-check every `fromMap` key against:
  - `baller_app/lib/supabase/court_services.dart` → `.from('courts').insert({...})`
  - `baller_app/lib/pages/Map/map_page.dart` → `.from('courts').select().eq('status', 'approved')` then `Court.fromMap(e)`
- Imports at call sites use package style: `import 'package:baller_app/models/Court.dart';` (see `map_page.dart`, `create_map_window.dart`, `court_details_page.dart`).
- Do **not** change widgets, auth, or Edge Functions in this skill’s scope.

### `courts` column ↔ Dart mapping (from `court_services.dart`)

| DB key (`map['…']`) | Insert source in `CourtServices.createCourt` | Suggested Dart field | `fromMap` notes |
|---------------------|-----------------------------------------------|----------------------|-----------------|
| `id` | returned via `.select('id').single()` | `String id` | `map['id'] as String` |
| `name` | `name` param | `String name` | `map['name'] ?? ''` |
| `lat` | `latitude` param | `double lat` | `(map['lat'] as num).toDouble()` |
| `lng` | `longitude` param | `double lng` | `(map['lng'] as num).toDouble()` |
| `indoor` | `indoor` param | `bool indoor` | `map['indoor'] ?? false` |
| `lights` | `hasLights` param | `bool? lights` or `bool lights` | prefer `?? false` if always selected |
| `has_markings` | `hasCourtMarkings` param | `bool? hasMarkings` | key is `has_markings`, not camelCase |
| `surface` | `groundType` param | `String? surface` | nullable if not in all selects |
| `hoops` | `hoops` param | `int? hoops` | `(map['hoops'] as num?)?.toInt()` if nullable |
| `address` | `address` param | `String? address` | `map['address'] as String?` |
| `source` | hardcoded `'community'` | optional `String? source` | only if UI reads it |
| `status` | not in insert (filtered on read) | usually omit from model | map page filters `eq('status', 'approved')` |

## Instructions

1. **Inventory persisted fields**
   - Read `baller_app/lib/supabase/court_services.dart` `createCourt` insert map (lines 19–29).
   - Read `baller_app/lib/pages/Map/map_page.dart` `fetchCourts()` — bare `.select()` returns all columns for approved rows.
   - List each DB key the UI or service needs on read.
   - **Verify:** you have a written list of DB keys and intended Dart field names before Step 2.

2. **Scaffold or extend `baller_app/lib/models/Court.dart`**
   - Mirror the existing shape (no extra imports in the model file today):

```dart
class Court {
  final String id;
  final String name;
  // add new finals here

  Court({
    required this.id,
    required this.name,
    // required this.newField for non-nullable
  });

  factory Court.fromMap(Map<String, dynamic> map) { ... }
}
```
   - Use `final` for all stored fields; `required` in the constructor for non-nullable fields.
   - **Verify:** class name is `Court`, file is `Court.dart`, and every new field appears in both the constructor and `fromMap` before Step 3.
   - **Uses output from Step 1.**

3. **Implement `fromMap` with project cast style**
   - Copy patterns from the current `Court.fromMap`:
     - **String (required):** `id: map['id'] as String`
     - **String (default empty):** `name: map['name'] ?? ''`
     - **double:** `lat: (map['lat'] as num).toDouble()`
     - **bool (default false):** `indoor: map['indoor'] ?? false`
   - For columns only present on some rows (or future selects), use nullable Dart types and safe casts:
     - `lights: map['lights'] as bool?` or `map['lights'] ?? false`
     - `hasMarkings: map['has_markings'] as bool?` — **never** `map['hasMarkings']`
     - `surface: map['surface'] as String?`
     - `hoops: map['hoops'] == null ? null : (map['hoops'] as num).toInt()`
   - **Verify:** every `map['key']` uses the **DB snake_case** name; run a mental diff against the insert map in `court_services.dart` before Step 4.
   - **Uses output from Step 2.**

4. **Align service parameter names vs DB keys (do not conflate)**
   - `CourtServices.createCourt` uses Dart named params (`hasLights`, `hasCourtMarkings`, `groundType`) but writes DB keys (`lights`, `has_markings`, `surface`). The **model reads DB keys only** in `fromMap`.
   - If you add a field to the model that `createCourt` already persists, do **not** rename DB columns — only add the `fromMap` entry.
   - If you add a **new** persisted field, update the insert map in `court_services.dart` in a separate change (or same task if requested); keep keys snake_case.
   - **Verify:** each insert key in `court_services.dart` that should round-trip on read has a matching `fromMap` line (nullable if `select()` may omit it).
   - **Uses output from Step 3.**

5. **Preserve call-site compatibility**
   - Keep `baller_app/lib/pages/Map/map_page.dart` mapping unchanged unless types force a cast:
     - `courts = data.map((e) => Court.fromMap(e)).toList();`
   - If analyzer complains about `dynamic` elements, use:
     - `data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();`
   - Do not switch call sites to `fromJson` unless the whole project migrates.
   - **Verify:** `grep -r "Court\." baller_app/lib` — any new non-nullable field must not break existing uses (`court.name`, `court.lat`, `court.lng`, `court.id` in `map_page.dart`).
   - **Uses output from Step 3.**

6. **Run analyzer from the Flutter app root**
   - From `baller_app/`:
     - `dart format lib/models/Court.dart`
     - `flutter analyze lib/models lib/supabase lib/pages/Map`
   - **Verify:** zero analyzer errors in touched paths before completing.
   - **Uses output from Steps 2–5.**

## Examples

### Example: Add court metadata fields already written by `createCourt`

**User says:** "Map `lights`, markings, surface, hoops, and address on `Court`."

**Actions taken:**
1. Open `baller_app/lib/supabase/court_services.dart` and confirm insert keys: `lights`, `has_markings`, `surface`, `hoops`, `address`.
2. Edit `baller_app/lib/models/Court.dart` — add `final` fields (nullable where selects may omit data).
3. Extend `Court.fromMap`:

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
4. Leave `map_page.dart` as `Court.fromMap(e)`.
5. Run `flutter analyze lib/models lib/supabase lib/pages/Map` from `baller_app/`.

**Result:** `Court` matches rows from `courts` selects and insert payloads; map list loading unchanged; no `toJson` added.

### Example: New model file (only when table is not `courts`)

**User says:** "Add a `CourtPhoto` model for storage metadata."

**Actions taken:**
1. Create `baller_app/lib/models/CourtPhoto.dart` with `class CourtPhoto`, `final` fields, `CourtPhoto({required ...})`, `factory CourtPhoto.fromMap(Map<String, dynamic> map)`.
2. Use snake_case `map['court_id']` keys matching the Supabase table.
3. Import where needed: `import 'package:baller_app/models/CourtPhoto.dart';`
4. Run `flutter analyze lib/models/<file>.dart`.

**Result:** New entity follows the same conventions as `Court.dart` without introducing `fromJson`/`toJson`.

## Common Issues

- **`type 'Null' is not a subtype of type 'String' in type cast`** on `map['id'] as String`:
  1. Row missing `id` in the select — ensure `.select()` includes `id` or use `map['id'] as String?` and nullable `id`.
  2. Re-run `flutter analyze lib/models/Court.dart`.

- **`type 'Null' is not a subtype of type 'num' in type cast`** on `(map['lat'] as num).toDouble()`:
  1. Column is null in DB — change field to `double?` and map with `map['lat'] == null ? null : (map['lat'] as num).toDouble()`.
  2. Confirm UI handles null (`map_page.dart` uses `court.lat` / `court.lng` for markers).

- **Field always null at runtime but insert sends a value:**
  1. Wrong map key — e.g. `map['hasMarkings']` instead of `map['has_markings']`.
  2. Fix `fromMap` to use the insert key from `court_services.dart` (`lights`, not `hasLights`).

- **`The argument type 'List<dynamic>' can't be assigned to the parameter type 'List<Court>'`:**
  1. In `baller_app/lib/pages/Map/map_page.dart`, cast elements: `data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();`
  2. Run `flutter analyze lib/pages/Map/map_page.dart`.

- **`Undefined name 'Court'`:**
  1. Use `import 'package:baller_app/models/Court.dart';` (package name from `baller_app/pubspec.yaml`: `name: baller_app`).
  2. Match filename casing exactly: `Court.dart`, not `court.dart`.

- **Analyzer: "All final variables must be initialized" after adding fields:**
  1. Add the field to the constructor with `required` (non-nullable) or give a default.
  2. Assign it inside `fromMap`.

- **`.cursor/rules/flutter-conventions.mdc` mentions `fromJson`/`toJson` but `Court.dart` does not:**
  1. For `Court` and sibling models in this app snapshot, follow **`fromMap` only** unless the user requests a repo-wide migration.
  2. Do not add `toJson` for symmetry with the rules file alone.