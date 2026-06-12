# BallerApp Design System (Flutter)

**Single source for UI widgets.** Pages compose only from here — no ad-hoc styled widgets in `pages/`.

## Layout

```
design_system/
  tokens/           # colors, typography, spacing, radius, elevation, motion
  extensions/       # ThemeExtension classes
  components/
    primitives/     # BallerText, BallerIcon, BallerSkeleton, …
    inputs/         # BallerButton, BallerTextField, …
    surfaces/       # BallerCard, BallerSheet, BallerEmptyState, …
    navigation/     # BallerAppBar, BallerBottomNav, …
    domain/         # BallerCourtCard, BallerGameCard, …
  app_theme.dart    # wires tokens into MaterialApp
```

## Rules

1. Tokens from `baller-design-knowledge.md` + `design/handoff/token-map.json` — never hardcode hex in components.
2. Every interactive component: all states (default, focus, pressed, disabled, loading, error).
3. Design in Pencil first (`baller_app/design/baller-app.pen`); implement matching name here.
4. Old widgets in `lib/widgets/` → migrate here, then delete duplicates.

## Import in pages

```dart
import 'package:baller_app/design_system/components/inputs/baller_button.dart';
```
