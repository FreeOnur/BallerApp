# Design Handoff (Claude Design → Flutter)

Integrate a **Claude Design handoff bundle** into BallerApp Flutter.

## Input

User provides: handoff URL (`api.anthropic.com/v1/design/h/...`) OR local extracted bundle path.

If URL: fetch bundle, read included README/manifest.

## Read first (authoritative — wins over bundle on conflict)

- `baller_app/DESIGN.md`
- `baller_app/baller-design-knowledge.md`
- `baller_app/design/handoff/design-manifest.md`
- `baller_app/design/handoff/token-map.json`

## Integration steps

1. Inspect handoff manifest — list components and screens
2. **Token conflicts:** prefer `DESIGN.md` / existing `lib/design_system/tokens/` — never add Inter or purple from bundle
3. Create/update Dart files in `baller_app/lib/design_system/components/` only:
   - `primitives/` · `inputs/` · `surfaces/` · `navigation/` · `domain/`
4. One Dart class per design component, same name (`BallerButton`, etc.)
5. All interactive states: default, focus, pressed, disabled, loading, error
6. Refactor affected `lib/pages/` to import from `design_system/` — remove ad-hoc styling
7. Do **not** add Supabase/API calls in widgets — repositories only
8. `cd baller_app && flutter analyze`
9. Update `design-manifest.md` — mark components done

## Optional local bundle path

Save exports under `baller_app/design/handoff/bundles/<yyyy-mm-dd>/`

## Output

- Files created/modified under `design_system/`
- Pages still on legacy widgets (list)
- Manifest updated
