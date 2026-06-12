# BallerApp Design Manifest

> Aus Pencil exportieren / pflegen. Flutter: `lib/design_system/components/` — **gleiche Namen**.

## Token sync

- Source: `handoff/token-map.json`
- Flutter: `lib/design_system/tokens/`
- Last sync: YYYY-MM-DD

## Component library (Pencil frame: `Components`)

| Component | Pencil node / frame | Flutter path | States done |
|-----------|---------------------|--------------|-------------|
| BallerButton | | `components/inputs/baller_button.dart` | |
| BallerTextField | | `components/inputs/baller_text_field.dart` | |
| BallerCourtCard | | `components/domain/baller_court_card.dart` | |
| BallerBottomNav | | `components/navigation/baller_bottom_nav.dart` | |
| … | | | |

## Screens (Pencil frame: `Screens`)

| Screen | Pencil frame | Flutter page | Uses components |
|--------|--------------|--------------|-----------------|
| Login | | `pages/.../login_page.dart` | BallerButton, BallerTextField |
| Map | | `pages/Map/map_page.dart` | BallerCourtMarker, BallerSheet |
| … | | | |

## Slop gate

- [ ] PASS @50-baller-design-audit-manual on full manifest
