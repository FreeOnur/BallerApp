# Changelog (AI-assisted and notable changes)

Append after each significant modification. See `.cursor/workflow.md`.

Format:

- **File(s) changed:** …
- **Reason:** …
- **Impact:** (e.g. UI only, service, security, config)

---

**2026-06-07** — Sync Cursor workflow, commands, and AI context with current rules

- **File(s) changed:** `.cursor/workflow.md`, `.cursor/ai/**`, `.cursor/commands/**` (removed duplicate `refactor.md`)
- **Reason:** Old workflow referenced deleted rules (`00_global_*`, `12_stitch_ui`, `06_security`); align with Baller design rules, Hallmark/PencilPlaybook, FastAPI/repository stack, anti-slop CI, Caliber.
- **Impact:** Config/docs only; no app logic modified.

---

**2025-02-20** — AI rule system audit and completion

- **File(s) changed:** `.cursor/rules/**`, `.cursor/ai/**`, `.cursor/workflow.md`
- **Reason:** Complete modular AI rules, security, memory, workflow.
- **Impact:** Config/docs only.

---
