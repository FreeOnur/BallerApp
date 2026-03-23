# Project Context — Baller App

Brief context for AI and developers. Update when architecture or conventions change.

## Stack

- **Flutter** (SDK ^3.9.0), **Supabase** (auth + backend)
- **Packages:** supabase_flutter, image_picker, http, dio, google_maps_flutter, geolocator, shared_preferences, url_launcher

## Structure

- `lib/auth/` — authentication (e.g. AuthGate)
- `lib/pages/` — full-screen UI only; no direct backend calls
- `lib/widgets/` — reusable UI (buttons, text fields, popups)
- `lib/services/` — business logic, HTTP, validation
- `lib/supabase/` — Supabase client usage (e.g. CourtServices); called via services or from pages via services
- `lib/models/` — data models (fromJson/toJson, no logic)
- `lib/theme/` — colors, spacing, sizes

## Conventions

- Pages and widgets do not call Supabase or API directly; they use services.
- Auth: use Supabase session only; no hardcoded user ids.
- Secrets: move to env/build config (see `.cursor/ai/security/security_checks.md`).
- Rules: `.cursor/rules/00_global_rules.md` through `10_performance_rules.md`; lower number wins on conflict.

## AI Workflow

Before coding: read rules, analyze existing code, plan minimal change.
After coding: update this changelog (`.cursor/ai/changes/changelog.md`), append prompt history (`.cursor/ai/prompts/prompt_history.md`), run security checklist (`.cursor/ai/security/security_checks.md`).
