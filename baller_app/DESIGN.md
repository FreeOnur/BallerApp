---
name: baller-app
platform: flutter
target: mobile
framework: flutter
component_library: baller_app/lib/design_system/components/
theme_path: baller_app/lib/design_system/
design_knowledge: baller_app/baller-design-knowledge.md
---

# BallerApp — Design System (authoritative for Claude Design)

Claude Design and Claude Code **must use these tokens** — do not invent Inter, purple gradients, or Material defaults.

Full spec: `baller-design-knowledge.md`

## Brand

- **Tone:** editorial-meets-streetball (Slam × SNKRS × Vercel discipline)
- **Mode:** dark default
- **Accent:** `#FC4C02` (Signal-Orange) — one sharp accent only
- **Never:** indigo/purple gradients, Inter/Roboto as display, 3-card grids, centered heroes, glassmorphism, emoji icons

## Colors

| Token | Hex |
|-------|-----|
| surface | `#1A1B1E` |
| surfaceMuted | `#25262B` |
| ink | `#F1F5F9` |
| inkMuted | `#94A3B8` |
| inkSubtle | `#64748B` |
| court (accent) | `#FC4C02` |
| success | `#22C55E` |
| warning | `#EAB308` |
| danger | `#EF4444` |
| outline | `rgba(255,255,255,0.08)` |

## Typography

- **Display:** Anton or Barlow Condensed (heavy condensed)
- **Body:** IBM Plex Sans
- **Scores/stats:** tabular figures mandatory
- Scale: 12 · 14 · 16 · 18 · 24 · 30 · 48 · 72

## Spacing & shape

- Grid: 4 · 8 · 16 · 24 · 32 · 48 · 96
- Radius: sharp 4px / 8px; pill 9999 only for chips
- Touch min: 48dp

## Component naming (Flutter = Claude Design)

All components prefixed `Baller`. Save Flutter code under:

```
baller_app/lib/design_system/components/
  primitives/   BallerText, BallerIcon, BallerSkeleton
  inputs/       BallerButton, BallerTextField, …
  surfaces/     BallerCard, BallerSheet, BallerEmptyState, …
  navigation/   BallerAppBar, BallerBottomNav, …
  domain/       BallerCourtCard, BallerGameCard, …
```

Pages in `lib/pages/` compose **only** from `design_system/components/` — no inline styling.

## Required component library (build in Claude Design first)

**Inputs:** BallerButton, BallerTextField, BallerPasswordField, BallerSearchField, BallerCheckbox  
**Surfaces:** BallerCard, BallerSheet, BallerEmptyState, BallerErrorState, BallerBanner  
**Nav:** BallerAppBar, BallerBottomNav  
**Domain:** BallerCourtCard, BallerCourtDetailHeader, BallerDistanceLabel, BallerCourtMarker  

## Screens to prototype

Login · Register · Profile Creation · Home · Map · Court Detail · Add Court · Settings

## Handoff rules

When exporting to Claude Code / Cursor:

1. Prefer existing tokens in this file over bundle defaults on conflict
2. Map each design component → one Dart file in `design_system/components/`
3. Repository pattern for data — UI only in handoff
4. Run slop gate: no purple, no Inter display, no 3-card template
