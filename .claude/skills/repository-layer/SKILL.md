---
name: repository-layer
description: Adds or extends Flutter repositories in baller_app/lib/repositories/ wired through repository_provider.dart for API vs Supabase dual-mode access. Handles ApiAuthRepository, CourtRepository, ProfileRepository, Bearer tokens via ApiClient/TokenStorage, and snake_case wire keys. Use when the user says add repository, wire court fetch, dual-mode data access, or edits *_repository.dart or repository_provider.dart. Do NOT use for FastAPI-only backend routes (fastapi-router), Postgres schema (postgres-migrations), auth gate/UI flows alone (auth-flow), or Court.fromMap field mapping (court-model).
paths:
  - baller_app/lib/repositories/**
  - baller_app/lib/core/api/**
  - baller_app/lib/supabase/court_services.dart
---
# Repository Layer

## Critical

- **All data access for courts/profiles/auth goes through `baller_app/lib/repositories/`**, exposed via static getters on `RepositoryProvider` — never add new `Supabase.instance.client.from(...)` calls in widgets or pages.
- **Mode switch is build-time:** `AppConfig.useLegacySupabase` from `--dart-define=USE_LEGACY_SUPABASE` (`baller_app/lib/core/config/app_config.dart`). Default is `true` (legacy Supabase).
- **Auth implementation is swapped in `repository_provider.dart` only:**
  - `true` → `SupabaseAuthRepository()` (`supabase_auth_repository.dart`)
  - `false` → `ApiAuthRepository()` (`api_auth_repository.dart`)
- **Domain repos (`CourtRepository`, `ProfileRepository`) branch inside each method** with `if (AppConfig.useLegacySupabase) { ... } else { ... }` — do not create separate `ApiCourtRepository` / `SupabaseCourtRepository` classes unless the user explicitly requests a refactor.
- **API mode HTTP:** all authenticated calls use `ApiClient` (`baller_app/lib/core/api/api_client.dart`), which attaches `Authorization: Bearer <access_token>` from `TokenStorage` via a Dio interceptor. Repositories must not manually set Bearer headers.
- **API base URL:** `AppConfig.apiBaseUrl` (default `http://10.0.2.2:8000` for Android emulator). Physical device needs host LAN IP.
- **Return raw maps from repositories; map to models at the call site:** e.g. `data.map((e) => Court.fromMap(e)).toList()` in `baller_app/lib/pages/Map/`. Repositories return `List<Map<String, dynamic>>` or scalar IDs — not `Court` objects.
- **Snake_case on the wire:** API POST/PUT bodies and Supabase insert maps use DB keys (`has_markings`, `skill_level`, `avatar_url`). Dart method params stay camelCase (`hasCourtMarkings`, `skillLevel`, `avatarUrl`).
- **Package imports only:** `import 'package:baller_app/repositories/...';` — no relative `../` paths.
- **Optional constructor injection** for tests: `{ApiClient? apiClient}`, `{CourtRepository? courtRepository}` — mirror existing repos.
- **Before adding endpoints**, read the matching FastAPI router under `backend/app/routers/`. Do not invent URL paths.
- **Do not store tokens in `SharedPreferences`.** Auth tokens live in `TokenStorage` (`baller_app/lib/core/api/token_storage.dart`) → `flutter_secure_storage` only.
- **Repository files (do not scatter logic elsewhere):** `auth_repository.dart` (abstract), `api_auth_repository.dart`, `supabase_auth_repository.dart`, `auth_result.dart`, `court_repository.dart`, `profile_repository.dart`, `repository_provider.dart`.

### Canonical `RepositoryProvider`

```dart
class RepositoryProvider {
  RepositoryProvider._();

  static final AuthRepository auth = AppConfig.useLegacySupabase
      ? SupabaseAuthRepository()
      : ApiAuthRepository();

  static final ProfileRepository profiles = ProfileRepository();
  static final CourtRepository courts = CourtRepository();
}
```

### Endpoint map (API mode)

| Repository method | HTTP | Path | Auth |
|-------------------|------|------|------|
| `ApiAuthRepository.signInWithEmailPassword` | POST | `/auth/login` | No |
| `ApiAuthRepository.signUp` | POST | `/auth/register` | No |
| `ApiAuthRepository.signOut` | POST | `/auth/logout` | Bearer (best-effort) |
| `ProfileRepository.hasProfile` | GET | `/profiles/me` | Bearer |
| `ProfileRepository.upsertProfile` | PUT | `/profiles/me` | Bearer |
| `CourtRepository.fetchApprovedCourts` | GET | `/courts` | No |
| `CourtRepository.createCourt` | POST | `/courts` | Bearer |

## Instructions

1. **Confirm mode and backend contract**
   - Read `docs/DEPLOY.md` and the target router in `backend/app/routers/`.
   - Grep existing repos:

```bash
cd baller_app && grep -r "RepositoryProvider\|AppConfig.useLegacySupabase" lib/
```

   - **Verify:** HTTP method, path, request/response JSON shape, and whether the route requires Bearer auth before Step 2.

2. **Choose repository type** (uses output from Step 1)
   - **New auth capability** → extend `AuthRepository` in `auth_repository.dart`; implement in `api_auth_repository.dart` and `supabase_auth_repository.dart`; delegate from `AuthService` (`baller_app/lib/auth/auth_service.dart`).
   - **New domain entity** → create `baller_app/lib/repositories/<entity>_repository.dart` with class `<Entity>Repository`.
   - **Extend existing** → edit `court_repository.dart` or `profile_repository.dart`; keep dual-mode branching.
   - **Verify:** file name is `snake_case.dart`, class name is `PascalCaseRepository`.

3. **Scaffold a domain repository** (for new entities; mirror `court_repository.dart`)

```dart
import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExampleRepository {
  ExampleRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchItems() async {
    if (AppConfig.useLegacySupabase) {
      final res = await Supabase.instance.client.from('items').select();
      return List<Map<String, dynamic>>.from(res as List);
    }
    final res = await _apiClient.dio.get('/items');
    return List<Map<String, dynamic>>.from(res.data as List);
  }
}
```

   - **Verify:** `ApiClient` injected once; legacy branch uses `Supabase.instance.client`; API branch uses `_apiClient.dio`.

4. **Implement API-mode HTTP calls** (uses Step 3 scaffold)
   - GET list: `final res = await _apiClient.dio.get('/courts');` → `List<Map<String, dynamic>>.from(res.data as List)`.
   - POST create: `final res = await _apiClient.dio.post('/courts', data: {...});` → cast `res.data as Map<String, dynamic>`.
   - PUT upsert: `await _apiClient.dio.put('/profiles/me', data: {...});`.
   - Cast response fields explicitly: `data['id'] as String`, `(map['lat'] as num).toDouble()`.
   - Court create wire map (both branches use identical snake_case keys; Dart params stay camelCase):

```dart
final body = {
  'name': name,
  'lat': latitude,
  'lng': longitude,
  'indoor': indoor,
  'lights': hasLights,
  'has_markings': hasCourtMarkings,
  'surface': groundType,
  'hoops': hoops,
  'address': address,
};
// legacy: Supabase.instance.client.from('courts').insert({...body, 'source': 'community', 'status': 'pending'})
// API: _apiClient.dio.post('/courts', data: body)
```

   - Auth methods return `AuthResult` from `auth_result.dart`; API login persists via `_tokenStorage.saveTokens(accessToken: data['access_token'], refreshToken: data['refresh_token'], userId: data['user_id'])`.
   - **Verify:** every `data` key matches the FastAPI Pydantic model field names (snake_case).

5. **Implement legacy Supabase branch** (same method, before or after API branch — match existing file style)
   - Copy insert/select patterns from `court_repository.dart` and `profile_repository.dart`.
   - Approved courts: `.from('courts').select().eq('status', 'approved')`.
   - User-scoped reads: `Supabase.instance.client.auth.currentUser` guard where applicable.
   - **Verify:** Supabase `.from('table')` keys match `backend/migrations/` column names.

6. **Wire into `repository_provider.dart`** (uses Step 3 or 4 output)

```dart
static final ExampleRepository examples = ExampleRepository();
```

   - Add import: `import 'package:baller_app/repositories/example_repository.dart';`
   - Auth swap stays unchanged unless adding a new auth backend.
   - **Verify:** `cd baller_app && flutter analyze` resolves the new import; no duplicate singletons elsewhere.

7. **Expose to UI through existing facades** (uses Step 6)
   - Pages/widgets call `RepositoryProvider.<repo>.<method>()` directly (see `baller_app/lib/pages/Map/`) **or** through a thin service wrapper (`baller_app/lib/supabase/court_services.dart` delegating to `RepositoryProvider.courts`).
   - Auth flows go through `AuthService`, which defaults to `RepositoryProvider.auth` / `.profiles`.
   - Map repository maps to models at the call site:

```dart
final data = await RepositoryProvider.courts.fetchApprovedCourts();
courts = data.map((e) => Court.fromMap(e)).toList();
```

   - **Verify:** no `Supabase.instance.client` imports added to page files.

8. **Handle API-only auth helpers** (uses Step 6)
   - `AuthRepository.getCurrentUserId()` returns `null` synchronously in API mode by design.
   - Gate/profile code that needs user ID must cast and call async helper:

```dart
final apiAuth = RepositoryProvider.auth as ApiAuthRepository;
final userId = await apiAuth.getUserIdAsync();
```

   - Or use `AuthService.resolveUserId()` which wraps this pattern.
   - **Verify:** no synchronous `getCurrentUserId()` reliance when `USE_LEGACY_SUPABASE=false`.

9. **Validate locally**

```bash
cd backend && docker compose -f docker-compose.dev.yml up -d --build
curl -s http://localhost:8000/health
```

```bash
cd baller_app && dart format lib/repositories/ lib/core/api/
cd baller_app && flutter analyze
cd baller_app && flutter test
```

   API mode run:

```bash
cd baller_app && flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

   Legacy mode run:

```bash
cd baller_app && flutter run --dart-define=USE_LEGACY_SUPABASE=true --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

   - **Verify:** target flow works in the mode you changed; analyze reports zero errors.

## Examples

### User says: "Wire court fetch through the repository instead of inline Supabase"

**Actions:**
1. Confirm `CourtRepository.fetchApprovedCourts()` in `court_repository.dart` (dual-mode GET `/courts` + Supabase `eq('status', 'approved')`).
2. In the map page, replace direct Supabase query with:

```dart
final data = await RepositoryProvider.courts.fetchApprovedCourts();
courts = data.map((e) => Court.fromMap(e)).toList();
```

3. Run `cd baller_app && flutter analyze`.

**Result:** Page works in both legacy and API mode; map markers populate from `RepositoryProvider.courts`.

### User says: "Add a repository method to update profile skill level"

**Actions:**
1. Read `backend/app/routers/profiles.py` — `PUT /profiles/me` accepts `skill_level`.
2. Add optional param to `ProfileRepository.upsertProfile` with dual branch:
   - Legacy: include `'skill_level': skillLevel` in Supabase upsert map.
   - API: include `'skill_level': skillLevel` in Dio PUT body.
3. Call from `AuthService.createProfile` if needed — it already delegates to `_profiles.upsertProfile(...)`.
4. Run `cd baller_app && flutter analyze`.

**Result:** Profile update works through repository; `AuthGate` profile check unchanged.

### User says: "Add ApiAuthRepository login for self-hosted backend"

**Actions:**
1. Confirm `repository_provider.dart` selects `ApiAuthRepository()` when `useLegacySupabase` is false.
2. `ApiAuthRepository.signInWithEmailPassword` POSTs to `/auth/login`, calls `_persistTokens` with `access_token`, `refresh_token`, `user_id` from response.
3. Subsequent `ProfileRepository.hasProfile` GET `/profiles/me` auto-includes Bearer via `ApiClient` interceptor.
4. Test: register/login → `AuthGate` reaches `MainPage` or `ProfileCreationPage`.

**Result:** Tokens in secure storage; authenticated repository calls succeed without manual headers.

## Common Issues

- **`Connection refused` / `DioException [connection error]` to `10.0.2.2:8000`:**
  1. Start API: `cd backend && docker compose -f docker-compose.dev.yml up -d --build`
  2. Confirm: `curl -s http://localhost:8000/health`
  3. Android emulator uses `10.0.2.2`; iOS simulator uses `http://localhost:8000`; physical device uses your machine's LAN IP in `--dart-define=API_BASE_URL=http://192.168.x.x:8000`

- **`401 Unauthorized` on `/profiles/me` or `POST /courts`:**
  1. Confirm login/register ran and `ApiAuthRepository._persistTokens` saved tokens.
  2. Verify request goes through `_apiClient.dio`, not raw `http`/`Dio` without interceptor.
  3. Check `TokenStorage.hasSession()` returns true after login.

- **`USE_LEGACY_SUPABASE=true requires SUPABASE_URL and SUPABASE_ANON_KEY` at startup:**
  1. Pass both dart-defines when running legacy mode.
  2. Or switch to API mode: `--dart-define=USE_LEGACY_SUPABASE=false`.

- **`type 'Null' is not a subtype of type 'String'` in repository:**
  1. Response key mismatch — API returns snake_case (`user_id`, `has_markings`); do not read camelCase from JSON.
  2. Add null-safe casts or defaults matching `Court.fromMap` patterns in `baller_app/lib/models/Court.dart`.

- **`getCurrentUserId()` always null in API mode:**
  1. Expected — secure storage is async.
  2. Use `await (RepositoryProvider.auth as ApiAuthRepository).getUserIdAsync()` or `AuthService.resolveUserId()`.

- **`PostgrestException: new row violates row-level security policy` (legacy mode):**
  1. User must be authenticated before insert.
  2. Confirm Supabase branch runs only when `AppConfig.useLegacySupabase` is true and session exists.

- **Approved courts empty in API mode but backend has rows:**
  1. `GET /courts` returns only `status = 'approved'` courts server-side.
  2. Newly created courts are `pending` until approved — same as legacy Supabase behavior.

- **Analyze error `Target of URI doesn't exist` for `package:baller_app/core/api/...`:**
  1. Run `cd baller_app && flutter pub get`.
  2. Confirm `dio` and `flutter_secure_storage` are in `baller_app/pubspec.yaml`.

- **Accidentally duplicated data layer:**
  1. If logic exists in `baller_app/lib/supabase/court_services.dart`, delegate to `RepositoryProvider.courts` instead of duplicating queries.
  2. Do not add parallel fetch helpers under `baller_app/lib/core/api/` outside repositories.