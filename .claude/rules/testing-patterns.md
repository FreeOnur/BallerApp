---
paths:
  - baller_app/test/**
  - **/*.spec.ts
  - **/*.test.ts
---

# Testing

## Flutter

```bash
cd baller_app && flutter analyze
cd baller_app && flutter test
```

- Add `baller_app/test/` for widget/model tests (directory may not exist yet).
- Model tests: `Court.fromMap` round-trip with sample row from `001_initial.sql` — no prod DB.
- Native smoke: `baller_app/ios/RunnerTests/RunnerTests.swift` · `macos/RunnerTests/RunnerTests.swift`.

## Playwright

- DevDep: root `package.json` → `@playwright/test`.
- Add root `playwright.config.ts` + `e2e/*.spec.ts` before expecting `npx playwright test` to pass.
- UI MCP: `.cursor/mcp.json` → `browser` server (`@playwright/mcp`).
