# Claude Design Session

Design BallerApp UI in **Claude Design** (claude.ai/design) — not Pencil.

## Prerequisites

- Design system published from `baller_app/DESIGN.md` + `baller-design-knowledge.md`
- See `.cursor/project/design-pipeline.md`

## Rules

- Dark UI, accent `#FC4C02`, Anton display, IBM Plex Sans body
- Build **Components** before **Screens**
- All components named `Baller*` — match Flutter paths in `design/handoff/design-manifest.md`
- Refuse: Inter display, purple gradients, 3-card grids, centered heroes, glassmorphism

## After session

1. Export → **Send to Claude Code** (handoff bundle)
2. Update `baller_app/design/handoff/design-manifest.md`
3. In Cursor run `/design-handoff` with the handoff URL

## User request

$ARGUMENTS
