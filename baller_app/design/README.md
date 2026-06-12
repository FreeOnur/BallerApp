# BallerApp — Design (Claude Design)

Design-Source via **[Claude Design](https://claude.ai/design)** — nicht Pencil.

## Setup (einmal)

1. Öffne [claude.ai/design](https://claude.ai/design) (Pro/Max/Team/Enterprise).
2. **Design System einrichten:** Repo/Codebase verbinden oder hochladen:
   - `baller_app/DESIGN.md` ← **authoritative für Claude Design**
   - `baller_app/baller-design-knowledge.md` ← vollständige Spec
   - `baller_app/design/claude-design-tokens.json` ← Token-Referenz
3. In Claude Design: Design System für Org/Project **publish** — danach nutzt jedes Projekt Baller-Tokens automatisch.

## Workflow

```
Claude Design (Screens + Components)
        ↓  Export → Handoff to Claude Code
Claude Code / Cursor (Flutter in lib/design_system/components/)
        ↓
Pages refactoren (nur DS-Components)
```

Details: `.cursor/project/design-pipeline.md`

## Handoff ablegen

Nach Export Bundle/URL in `design/handoff/` dokumentieren in `design-manifest.md`.

## Dateien

| Datei | Zweck |
|-------|--------|
| `../DESIGN.md` | Claude Design liest das beim Onboarding |
| `claude-design-tokens.json` | Token-JSON für Import |
| `handoff/design-manifest.md` | Komponenten-Inventar |
| `handoff/token-map.json` | Claude Design token → Flutter |

`pencil-preset-baller.json` — **deprecated**, nur Legacy-Referenz.
