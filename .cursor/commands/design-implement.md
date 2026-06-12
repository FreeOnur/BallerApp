# Design Implement (Pencil → Flutter)

Implement UI from Claude Design handoff or manifest into Flutter design system.

## Read first

- `baller_app/DESIGN.md`
- `baller_app/baller-design-knowledge.md`
- `baller_app/design/handoff/design-manifest.md`
- Handoff bundle README if available (from Claude Design export)

For handoff URL: use `/design-handoff` instead.

## Rules

1. Code goes in `baller_app/lib/design_system/components/` — **never** ad-hoc styling in `pages/`.
2. Use tokens from `design_system/tokens/` — match `token-map.json`; no hardcoded colors/spacing.
3. Component class name = manifest name (`BallerCourtCard`, etc.).
4. All interactive states: default, focus, pressed, disabled, loading, error.
5. Pages: replace old `lib/widgets/` usage with design_system imports only.
6. Run `cd baller_app && flutter analyze`.
7. Optional audit: `@50-baller-design-audit-manual` — no edits, punch list only.

## Output

- Files created under `design_system/`
- Manifest row updated (states done)
- List of pages still on legacy widgets
