---
paths:
  - baller_app/lib/**/*.dart
---

# Flutter Conventions

## Widgets

- Async shell pattern: `baller_app/lib/auth/auth_gate.dart` (loading + error branches).
- Theme: `app_colors.dart` · `app_spacing.dart` · `app_sizes` — no inline `Color(0xFF...)`.
- Package imports: `package:baller_app/...` from `pubspec.yaml` name `baller_app`.

## Data access

- Prefer `RepositoryProvider.courts` / `.profiles` / `.auth` over new `court_services.dart` methods when `USE_LEGACY_SUPABASE=false`.
- Legacy reads: `court_services.dart` → `Court.fromMap` on results.

## Services

- GPS: `LocationService.loadPosition()` in `load_position.dart` only.
- Profanity: `BadwordFilter.loadWords()` before `runApp` in `main.dart`.
