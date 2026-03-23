# Flutter Development Rules — Baller App

You are an expert Flutter engineer.

Follow official Flutter best practices.

---

## 1. Widget Structure

Prefer small composable widgets.

Rules:

- One widget = one responsibility
- Extract widgets when build() > 80 lines
- Avoid deeply nested widgets

Bad:
Page → 300 line build()

Good:
Page
→ HeaderWidget
→ GameListWidget
→ ActionButtonWidget

---

## 2. State Management

Rules:

- Keep state as local as possible
- Do NOT use global state unless necessary
- UI state stays inside widgets
- Business state belongs to services

Avoid:

- storing backend data directly in UI state

Prefer:

- FutureBuilder / StreamBuilder
- controller/service pattern

---

## 3. Build Method Safety

NEVER inside build():

- API calls
- database queries
- heavy calculations
- async logic

build() must be PURE UI.

---

## 4. Async Handling

Always:

- use async/await
- handle errors with try/catch
- return typed results

Never ignore Future errors.

Example:

try {
final games = await gameService.getGames();
} catch (e) {
handleError(e);
}

---

## 5. Navigation Rules

Navigation must:

- be centralized
- avoid inline navigation logic everywhere

Prefer:
Navigator.push(context, ...)

Avoid:
complex navigation inside widgets.

---

## 6. UI Performance

Avoid:

- unnecessary setState()
- rebuilding entire page
- large lists without builders

Always use:

- ListView.builder
- const constructors when possible

---

## 7. File Organization

Current Baller App layout:

- `lib/pages/` — full-screen UI
- `lib/widgets/` — reusable UI (buttons, text fields, popups)
- `lib/services/` — business logic, HTTP
- `lib/supabase/` — Supabase client usage (called from services or pages via services)
- `lib/models/` — data models
- `lib/theme/` — colors, spacing, sizes
- `lib/auth/` — authentication only

Never mix responsibilities. No API or database calls in build(); use services.

---

## 8. Theming

Use:
theme/

Never hardcode:

- colors
- font sizes
- spacing
- and never have speciific numbers in the code

Always use Theme.of(context).

---

## 9. Error Handling UI

Every async UI must handle:

- loading
- success
- error

No blank screens allowed.

---

## 10. Clean Code Rules

Prefer:

- final variables
- null safety
- meaningful naming

Avoid:
var unless obvious.

---

## 11. Supabase + Flutter

UI NEVER calls Supabase directly.

Flow:

Widget
→ Service
→ Supabase client
→ Model
→ UI

---

## 12. Rebuild Optimization

Use:
const widgets
separate widgets
ValueNotifier when lightweight

Avoid rebuilding parent widgets unnecessarily.

---

## 13. Security in Flutter Layer

Never:

- store tokens in widgets
- print auth tokens
- expose user ids manually

Auth comes ONLY from Supabase session.

---

## 14. Code Generation Behavior

When modifying UI:

- modify minimal widgets only
- do not rewrite entire page

When unsure:
ASK before refactor.
