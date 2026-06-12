# BallerApp — Design Pipeline (Claude Design → Flutter)

**Tool:** [Claude Design](https://claude.ai/design) → Handoff Bundle → **Claude Code / Cursor** → Flutter

```
┌──────────────────────┐     ┌────────────────────┐     ┌─────────────────────────────┐
│ claude.ai/design     │     │ design/handoff/    │     │ lib/design_system/          │
│ Component Library +  │ ──► │ manifest + bundle  │ ──► │ components/ + pages/        │
│ App Screens          │     │ (URL or export)    │     │ (Cursor / Claude Code)      │
└──────────────────────┘     └────────────────────┘     └─────────────────────────────┘
           ▲                                                          │
           │                                                          │
   DESIGN.md + baller-design-knowledge.md ◄───────────────────────────┘
```

**Nicht Pencil / PencilPlaybook** — BallerApp nutzt ausschließlich Claude Design für visuelles Design.

---

## Phase 0 — Einmal-Setup

| Schritt | Wo | Aktion |
|---------|-----|--------|
| 1 | claude.ai/design | Zugang (Pro/Max/Team/Enterprise) |
| 2 | Design System | Repo verbinden oder `baller_app/DESIGN.md` + `baller-design-knowledge.md` importieren |
| 3 | Publish | Design System in Claude Design veröffentlichen — alle Projekte nutzen Baller-Tokens |
| 4 | Optional | `baller_app/design/claude-design-tokens.json` als Token-Referenz |

Claude Design liest beim Onboarding die Codebase und baut daraus Colors, Typography, Components — **DESIGN.md ist authoritative**, bei Konflikten gewinnt DESIGN.md + `baller-design-knowledge.md`, nicht generierte Defaults.

---

## Phase 1 — Design in Claude Design

### Projekt-Struktur im Canvas

```
Project: BallerApp
├── Design System (auto from DESIGN.md)
├── Components              ← zuerst bauen
│   ├── BallerButton (+ states)
│   ├── BallerTextField
│   ├── BallerCourtCard
│   ├── BallerBottomNav
│   ├── BallerEmptyState
│   └── …
└── Screens                 ← nur aus Components
    ├── Login
    ├── Map
    ├── Court Detail
    └── …
```

### Reihenfolge

1. Design System prüfen (Orange `#FC4C02`, Anton, IBM Plex Sans, dark)
2. **Component Library** — alle `Baller*`-Widgets mit States (default, disabled, loading, error)
3. **Screens** — Mobile 390×844, nur Component-Instanzen
4. Inline-Kommentare für Iteration; Sliders für Spacing/Farbe
5. Slop-Check: kein Purple, kein Inter-Display, kein 3-Karten-Raster

### Start-Prompt (in Claude Design einfügen)

```
BallerApp — pickup basketball app, Flutter mobile, dark UI default.

Design system is already set from DESIGN.md: accent #FC4C02, display Anton, body IBM Plex Sans, asphalt gray surfaces, 8pt grid, sharp 4px radius.

Build the component library first (not screens):
BallerButton, BallerTextField, BallerPasswordField, BallerCourtCard, BallerBottomNav, BallerEmptyState, BallerSearchField, BallerAppBar.

Each component: default, disabled, loading, error variants. Editorial-streetball tone — no purple gradients, no Inter as display, no centered hero, no three feature cards, no glassmorphism.

Then scaffold screens using ONLY those components: Login, Map (full-bleed + search chip + bottom sheet), Court Detail (editorial header + spec rows).

Reference: baller-design-knowledge.md for full anti-slop rules.
```

---

## Phase 2 — Handoff zu Claude Code

In Claude Design wenn fertig:

1. **Export → Send to Claude Code** (Handoff Bundle)
   - Enthält: Component-Tree, Tokens, Layout, Assets — kein PNG-only
2. Oder: Handoff-URL kopieren (`api.anthropic.com/v1/design/h/...`)

In **Claude Code** oder **Cursor**:

```
/design-handoff <URL or path to extracted bundle>
```

Handoff-Regeln (in Prompt mitgeben):

```
Integrate this Claude Design handoff into BallerApp Flutter.

Authoritative design: baller_app/DESIGN.md and baller-design-knowledge.md.
On token conflict, prefer DESIGN.md — do not introduce Inter or purple.

Map each component to baller_app/lib/design_system/components/<category>/baller_*.dart.
Pages compose only from design_system — do not style in pages/.
Keep repository pattern — UI only, no new Supabase calls in widgets.
Run flutter analyze when done.
```

Bundle lokal speichern (optional): `baller_app/design/handoff/bundles/<date>/`

`design-manifest.md` aktualisieren: Component name, Flutter path, handoff date, states done.

---

## Phase 3 — Flutter in Cursor

Slash command: **`/design-implement`** oder **`/design-handoff`**

1. `DESIGN.md` + `design-manifest.md` + Handoff README lesen
2. Code **nur** in `lib/design_system/components/`
3. `token-map.json` ↔ `lib/design_system/tokens/` sync
4. Pages: `lib/widgets/*` durch DS-Imports ersetzen
5. `flutter analyze` + optional `@50-baller-design-audit-manual`

---

## Phase 4 — Full App Redesign

| # | Task |
|---|------|
| 1 | Claude Design: komplette Component Library |
| 2 | Claude Design: alle Screens (G1–G12) |
| 3 | Handoff pro Screen-Cluster oder ein Master-Handoff |
| 4 | Cursor: Tokens → Components → Pages (Reihenfolge!) |
| 5 | Alte Widgets löschen wenn ersetzt |
| 6 | Slop-Audit pro Screen |

---

## Cursor ↔ Claude Design

| Aufgabe | Tool |
|---------|------|
| Design / Prototype | Claude Design (claude.ai/design) |
| Handoff | Export → Claude Code |
| Flutter implementieren | Cursor + `/design-handoff` |
| Token-Änderung | DESIGN.md + design-knowledge → Claude Design System updaten → re-handoff |

---

## Referenz

| Was | Pfad |
|-----|------|
| Claude Design authority | `baller_app/DESIGN.md` |
| Full spec | `baller_app/baller-design-knowledge.md` |
| Handoff tracking | `baller_app/design/handoff/` |
| Flutter components | `baller_app/lib/design_system/components/` |
| Slop audit | `@50-baller-design-audit-manual` |
