---
name: auth-flow
description: Implements dual auth (legacy Supabase vs self-hosted JWT) across `auth_gate.dart`, `auth_service.dart`, `baller_app/lib/repositories/auth_*.dart`, and FastAPI `/auth/*`. Use when changing login, register, logout, refresh tokens, profile gating, password reset, or `USE_LEGACY_SUPABASE` / `API_BASE_URL` dart-defines. Covers `RepositoryProvider` wiring, `TokenStorage`, `ApiClient` Bearer injection, and `AuthGate` reload callbacks. Do NOT use for court CRUD-only changes, map/geolocation, Edge Functions, or Docker/Hetzner deploy.
paths:
  - baller_app/lib/auth/**
  - baller_app/lib/repositories/auth*.dart
  - baller_app/lib/repositories/repository_provider.dart
  - baller_app/lib/core/config/app_config.dart
  - baller_app/lib/core/api/**
  - baller_app/lib/pages/AuthenthicationPage/**
  - backend/app/routers/auth.py
  - backend/app/dependencies.py
  - docs/DEPLOY.md
---
# Auth Flow

## Critical

- **Mode switch is build-time only:** `AppConfig.useLegacySupabase` from `--dart-define=USE_LEGACY_SUPABASE` in `baller_app/lib/core/config/app_config.dart`. Default in repo is `true`; self-hosted dev uses `false`.
- **Never bypass the gate:** `baller_app/lib/main.dart` → `home: AuthGate()`. UI pages call `AuthService`, not `Supabase.instance.client.auth` or raw `dio.post('/auth/...')` directly.
- **Repository selection is centralized:** `baller_app/lib/repositories/repository_provider.dart` picks `SupabaseAuthRepository` vs `ApiAuthRepository`. Do not instantiate auth repos in widgets.
- **Tokens:** API mode stores `access_token`, `refresh_token`, `user_id` in `FlutterSecureStorage` via `baller_app/lib/core/api/token_storage.dart`. Never use `SharedPreferences` for tokens.
- **Legacy startup:** when `USE_LEGACY_SUPABASE=true`, `main.dart` requires `SUPABASE_URL` + `SUPABASE_ANON_KEY` or throws `StateError('USE_LEGACY_SUPABASE=true requires SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.')`. API mode does **not** call `Supabase.initialize`.
- **Password reset:** `AuthService.resetPasswordForEmail` is Supabase-only today; API mode throws `UnsupportedError('Use API forgot-password when USE_LEGACY_SUPABASE=false')` until `POST /auth/forgot-password` exists (`docs/DEPLOY.md`).
- **Token refresh gap:** backend exposes `POST /auth/refresh` in `backend/app/routers/auth.py`; Flutter `ApiClient` has request interceptor only — no 401 refresh retry yet. Add refresh in `ApiClient` / `ApiAuthRepository`, not ad-hoc per screen.
- **Cutover:** Supabase password hashes are not portable (`docs/DEPLOY.md`). Migrated users need a new password via forgot-password flow.

### Mode matrix

| Mode | dart-define | Auth impl | Session signal | Profile check |
|------|-------------|-----------|----------------|---------------|
| Legacy | `USE_LEGACY_SUPABASE=true` | `SupabaseAuthRepository` | `onAuthStateChange` | `ProfileRepository.hasProfile()` via Supabase `profiles` |
| API | `USE_LEGACY_SUPABASE=false` | `ApiAuthRepository` | `TokenStorage.hasSession()` | `GET /profiles/me` (Bearer via `ApiClient`) |

### API token contract (`TokenResponse`)

Login/register/refresh JSON keys: `access_token`, `refresh_token`, `user_id` (snake_case). `ApiAuthRepository._persistTokens` must keep these keys in sync with `backend/app/routers/auth.py`.

## Instructions

### 1. Confirm mode and backend before editing Dart

```bash
cd backend && docker compose -f docker-compose.dev.yml up -d --build
curl -s http://localhost:8000/health
```

Legacy Flutter run:

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=true \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

API Flutter run (Android emulator → host API):

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

**Verify:** `curl` health OK for API work; `AppConfig.useLegacySupabase` matches the dart-define you intend before Step 2.

### 2. Extend `AuthRepository` only when both backends need the same surface

Canonical interface: `baller_app/lib/repositories/auth_repository.dart`

```dart
abstract class AuthRepository {
  Future<AuthResult> signInWithEmailPassword(String email, String password);
  Future<AuthResult> signUp(String email, String password);
  Future<void> signOut();
  Future<bool> hasSession();
  String? getCurrentUserEmail();
  String? getCurrentUserId();
}
```

Return type: `baller_app/lib/repositories/auth_result.dart` → `AuthResult(userId:, email:)`.

Wire mode switch in `repository_provider.dart`:

```dart
static final AuthRepository auth = AppConfig.useLegacySupabase
    ? SupabaseAuthRepository()
    : ApiAuthRepository();
```

**Verify:** new method added to **both** `supabase_auth_repository.dart` and `api_auth_repository.dart`, plus `AuthService` delegate, before UI changes.

### 3. Implement Supabase path (`SupabaseAuthRepository`)

File: `baller_app/lib/repositories/supabase_auth_repository.dart`

Patterns already in repo:

- Sign-in: `_supabase.auth.signInWithPassword` → `AuthResult(userId: user.id, email: user.email)`; `user == null` → `Exception('Sign in failed')`.
- Sign-up: `_supabase.auth.signUp` then insert stub row into `profiles` (`id`, empty `username`, null optional fields).
- Session: `_supabase.auth.currentSession != null`.
- Sync IDs: `currentUser?.id` / `?.email`.

**Verify:** `cd baller_app && flutter analyze` clean; legacy run reaches `LoginPage` / `MainPage` without raw Supabase calls in pages.

### 4. Implement API path (`ApiAuthRepository`)

Files: `baller_app/lib/repositories/api_auth_repository.dart`, `baller_app/lib/core/api/api_client.dart`, `baller_app/lib/core/api/token_storage.dart`

Login/register pattern:

```dart
final res = await _client.dio.post(
  '/auth/login', // or '/auth/register'
  data: {'email': email, 'password': password},
);
final data = res.data as Map<String, dynamic>;
await _tokenStorage.saveTokens(
  accessToken: data['access_token'] as String,
  refreshToken: data['refresh_token'] as String,
  userId: data['user_id'] as String,
);
return AuthResult(userId: data['user_id'] as String, email: email);
```

Logout: `POST /auth/logout` with `{'refresh_token': refresh}` then `tokenStorage.clear()` (clear even if server fails).

`getCurrentUserId()` stays `null` (secure storage is async). Gate uses `getUserIdAsync()`.

`ApiClient` attaches Bearer token in `onRequest` via `TokenStorage.getAccessToken()`; `baseUrl` from `AppConfig.apiBaseUrl`.

**Verify:** after login, `TokenStorage.hasSession()` is true; `curl -H "Authorization: Bearer <access>" http://localhost:8000/profiles/me` returns 200.

### 5. Expose facades through `AuthService` (uses Step 2 output)

File: `baller_app/lib/auth/auth_service.dart`

- Construct with `authRepository ?? RepositoryProvider.auth` and `profileRepository ?? RepositoryProvider.profiles`.
- `resolveUserId()`: sync `getCurrentUserId()` first; if null and `ApiAuthRepository`, call `getUserIdAsync()`.
- `createProfile(...)`: `resolveUserId()` then `_profiles.upsertProfile(...)`; failures → `Exception('Failed to create profile: $e')`.

**Verify:** pages import `package:baller_app/auth/auth_service.dart` only — grep shows no new direct `RepositoryProvider.auth` in `lib/pages/`.

### 6. Keep `AuthGate` routing aligned with mode

File: `baller_app/lib/auth/auth_gate.dart`

**Legacy (`_LegacyAuthGate`):** `StreamBuilder<AuthState>` on `Supabase.instance.client.auth.onAuthStateChange` → waiting spinner → `session != null` → `FutureBuilder` on `RepositoryProvider.profiles.hasProfile()` → `MainPage` | `ProfileCreationPage` | `LoginPage`.

**API (`_ApiAuthGate`):** `_loadState()` (Step 4 output):
1. `RepositoryProvider.auth.hasSession()` → logged out if false.
2. Cast `RepositoryProvider.auth as ApiAuthRepository`; `getUserIdAsync()`.
3. `RepositoryProvider.profiles.hasProfile(userId: userId)` → `home` vs `needsProfile`.

Reload callbacks (API only):
- `LoginPage(onAuthSuccess: _reload)`
- `ProfileCreationPage(onProfileComplete: _reload)`

**Verify:** API login does not rely on `onAuthStateChange`; legacy gate does not call `TokenStorage`.

### 7. Wire auth pages (uses Step 5 output)

- `baller_app/lib/pages/AuthenthicationPage/Register/login_page.dart`: `AuthService().signInWithEmailPassword`; on success call `widget.onAuthSuccess?.call()` (required for API gate reload).
- `register_page.dart`: `signUp` then `Navigator.pushReplacement` → `ProfileCreationPage`.
- `profile_creation_page.dart`: `authService.createProfile(...)`; if `onProfileComplete != null` call it, else `Navigator.pushReplacement` → `MainPage`.

**Verify:** `cd baller_app && flutter analyze`; manual login → profile → home on both modes.

### 8. Backend auth changes (when adding endpoints)

Files: `backend/app/routers/auth.py`, `backend/app/security/jwt.py`, `backend/app/security/passwords.py`, schema `backend/migrations/001_initial.sql` (`users`, `refresh_tokens`).

- Register: `RegisterRequest` password `min_length=8`; creates `users` + empty `profiles` + refresh token row; returns `TokenResponse`.
- Login/refresh return same `TokenResponse` shape; refresh rotates token (delete old hash, insert new).
- Protected routes use `get_current_user_id` from `backend/app/dependencies.py` (`HTTPBearer`).

**Verify:**

```bash
curl -s -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password12"}'
curl -s -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password12"}'
```

Both return JSON with `access_token`, `refresh_token`, `user_id`.

### 9. Final validation

```bash
cd baller_app && dart format lib/auth/ lib/repositories/ lib/core/api/
cd baller_app && flutter analyze
cd baller_app && flutter test
```

**Verify:** no analyzer errors in auth paths; both run commands above behave as expected.

## Examples

### User: "Switch login to self-hosted JWT"

**Actions:**
1. Start API (`docker compose -f docker-compose.dev.yml up -d`).
2. Confirm `RepositoryProvider.auth` resolves to `ApiAuthRepository` when `USE_LEGACY_SUPABASE=false`.
3. Run app with `API_BASE_URL=http://10.0.2.2:8000`.
4. Login via `LoginPage` → tokens in `TokenStorage` → `AuthGate` `_reload` → `MainPage` if `/profiles/me` succeeds.

**Result:** No Supabase init in `main.dart`; `Authorization: Bearer` attached on `ApiClient` requests.

### User: "Add sign-out from settings"

**Actions:**
1. Call `await AuthService().signOut()` (not `Supabase.instance.client.auth.signOut()` unless legacy-only branch).
2. API: confirm `TokenStorage.clear()` even if `/auth/logout` fails.
3. Legacy: stream updates `AuthGate` automatically.
4. API: navigate to root / trigger gate rebuild so `_ApiAuthGate` reloads logged-out state.

**Result:** Session cleared per mode; user sees `LoginPage`.

### User: "Implement token refresh on 401"

**Actions:**
1. Add `ApiAuthRepository.refreshSession()` → `POST /auth/refresh` with stored refresh token → `_persistTokens`.
2. In `ApiClient` interceptor `onError`, on 401 call refresh once, retry request, else `clear()` and surface logged-out.
3. Do not store refreshed tokens in widgets.

**Result:** Matches backend rotation in `auth.py` `refresh` handler.

## Common Issues

- **`StateError: USE_LEGACY_SUPABASE=true requires SUPABASE_URL and SUPABASE_ANON_KEY`** — pass both dart-defines or set `USE_LEGACY_SUPABASE=false` for API-only dev.
- **`UnsupportedError: Use API forgot-password when USE_LEGACY_SUPABASE=false`** — expected until `AuthService.resetPasswordForEmail` calls new API; legacy reset uses `Supabase.instance.client.auth.resetPasswordForEmail` only.
- **`Connection refused` / Dio connection errors on login** — API not reachable: `docker compose -f backend/docker-compose.dev.yml ps`; emulator must use `http://10.0.2.2:8000`, not `localhost`.
- **`401 Unauthorized` on `/profiles/me` after login** — access token missing: confirm `_persistTokens` ran; `ApiClient` interceptor reads `TokenStorage.getAccessToken()`.
- **`type 'Null' is not a subtype of type 'String'` in `_persistTokens`** — API response missing `access_token` / `refresh_token` / `user_id`; align client with `TokenResponse` in `backend/app/routers/auth.py`.
- **`409 Conflict` / `Email already registered` on register** — duplicate email in `users` table; user should login instead.
- **`401 Invalid credentials` on login** — wrong password or user only exists in Supabase (not migrated to `users`); see `docs/DEPLOY.md`.
- **Logged in but gate shows `LoginPage` (API)** — `onAuthSuccess` not passed: `AuthGate` must use `LoginPage(onAuthSuccess: _reload)`; signing in without reload leaves stale `FutureBuilder`.
- **`getCurrentUserId()` always null in API mode** — by design; use `AuthService.resolveUserId()` or `ApiAuthRepository.getUserIdAsync()`.
- **Sign-up works but profile step skipped unexpectedly** — backend register inserts `profiles` row; `hasProfile` is true when `/profiles/me` returns 200. Adjust `hasProfile` logic only if product requires empty username to mean incomplete.
- **Legacy `PostgrestException` on profiles insert** — RLS or schema mismatch; stub insert keys must match `profiles` columns in `supabase_auth_repository.dart`.