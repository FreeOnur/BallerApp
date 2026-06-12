# Refactor Feature

Improve the selected feature without changing behavior unless explicitly requested.

## Goals

- Match `clean-code-checklist.mdc` and `flutter-conventions.mdc`
- Enforce repository pattern — move stray SDK calls behind repositories
- Reduce widget rebuilds; use Riverpod `select()` where helpful
- Remove duplication; keep diffs minimal

## Process

1. Read surrounding code and `.cursor/project/architecture.md`.
2. Plan smallest safe refactor; avoid drive-by changes.
3. Preserve public APIs unless user approved breaking changes.
4. Run `flutter analyze` after Dart edits.

## Output

Summary: what improved, files touched, any follow-up risks.
