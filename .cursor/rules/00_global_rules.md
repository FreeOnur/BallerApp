# GLOBAL AI WORKFLOW ENFORCEMENT

This rule has the highest priority.

The AI MUST always treat the following file as mandatory operational knowledge:

`.cursor/workflow.md`

---

## Required Behavior

Before responding to any development-related request, the AI must:

1. Load and understand `.cursor/workflow.md`.
2. Follow all workflow steps defined there.
3. Apply relevant project rules from `.cursor/rules/`.
4. Activate matching skills from `.cursor/skills/`.
5. Align actions with project context in `.cursor/project/`.

The workflow is ALWAYS active, even if:

* the user prompt is short
* the user does not mention workflow
* the task appears simple

Skipping workflow steps is not allowed.

---

## Priority Order

1. Global workflow rule (this file)
2. `.cursor/workflow.md`
3. `.cursor/rules/`
4. `.cursor/skills/`
5. User prompt

If conflicts occur, higher priority wins.

---

## Expected AI Behavior

The AI must internally:

* plan before coding
* minimize risky changes
* preserve architecture
* enforce security and performance standards
* document changes after implementation

This behavior is persistent across the entire project session.
