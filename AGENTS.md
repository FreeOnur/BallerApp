# BallerApp — Agent context

Pickup basketball app: Flutter (`baller_app/`) + FastAPI/PostGIS backend (`backend/`). See `CLAUDE.md` for architecture and commands.

## Cursor Cloud specific instructions

### Services (self-hosted path — default in Cloud VM)

| Service | How to start | Verify |
|---------|--------------|--------|
| **PostGIS + FastAPI** | See Docker below | `curl -s http://localhost:8000/health` → `{"status":"ok",...}` |
| **Flutter app** | `flutter run -d linux` or build only | `flutter analyze` in `baller_app/` |

Legacy Supabase mode needs hosted `SUPABASE_URL` + `SUPABASE_ANON_KEY` dart-defines; not configured in Cloud VM by default.

### Docker

- `docker-compose.yml` only **exposes** port 8000 inside the Compose network (for Coolify). For host access during local dev, add a ports override (do not commit):

```bash
cat > /tmp/compose-ports.yml << 'EOF'
services:
  api:
    ports:
      - "8000:8000"
EOF
cp backend/.env.example .env   # first time only
docker compose -f docker-compose.yml -f /tmp/compose-ports.yml up -d --build
```

- If `docker` permission errors occur, use `sudo docker …` or ensure the user is in the `docker` group (re-login after `usermod`).
- Cloud VMs may need `dockerd` started manually if the daemon is not running.

### Flutter SDK

- Installed at `/opt/flutter`. Add to PATH: `export PATH="/opt/flutter/bin:$PATH"`.
- **Linux desktop** builds need system packages: `ninja-build`, `libgtk-3-dev`, `build-essential`, `g++-14`, `libstdc++-14-dev` (clang links against GCC 14's libstdc++ on Ubuntu 24.04).
- **Web** build currently fails: `create_map_window.dart` imports `dart:ffi` (not available on web). Use Linux desktop or a mobile emulator for runnable UI.
- **Android/iOS** emulators are not preinstalled; `ANDROID_HOME` is unset. Use `flutter build linux` or API-level testing instead.

### Lint / test / run commands

See `CLAUDE.md`. Quick reference:

```bash
export PATH="/opt/flutter/bin:$PATH"
cd baller_app && flutter pub get && flutter analyze
curl -s http://localhost:8000/health
```

`flutter test` exits with "test directory not found" — no `test/` folder yet. Root `npx playwright test` has no `playwright.config` or specs.

### API-mode smoke (no Flutter UI)

```bash
curl -s -X POST http://localhost:8000/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"TestPass123!"}'
```

Use a normal email domain (e.g. `@example.com`); `.local` addresses are rejected by Pydantic `EmailStr`.

### Gotchas

- New courts are created with `status=pending`; `GET /courts` returns only `approved`. Approve in dev via `docker compose exec db psql -U baller -d baller -c "UPDATE courts SET status='approved' WHERE id='…';"`.
- B2 upload presign returns 503 without `B2_KEY_ID` / `B2_APP_KEY` in `.env` (optional for auth/courts smoke).
