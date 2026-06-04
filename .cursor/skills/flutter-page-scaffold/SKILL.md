---
name: flutter-page-scaffold
description: Creates a new Flutter page in `baller_app/lib/pages/` using the project’s StatefulWidget + Supabase loading pattern, theme tokens from `lib/theme/app_colors.dart` and `lib/theme/app_spacing.dart`, and direct `Navigator.push`/`MainPage` wiring. Use when user says "add page", "new screen", "create view", "add Flutter page", or asks to add files under `baller_app/lib/`. Key capabilities: scaffold file/folder naming, imports, async data method + loading/error UI, and navigation integration in `main_page.dart`/buttons. Do NOT use for editing an existing page’s internals, authentication flow rewrites, or non-Flutter files.
---
# Flutter Page Scaffold

## Critical

- Create new screens only under `baller_app/lib/pages/<FeatureName>/<feature_name>_page.dart`; do not place page widgets in `lib/widgets/`.
- Use `package:` imports with the app package name (`package:baller_app/...`), matching files like `lib/pages/Map/map_page.dart` and `lib/pages/Home/main_page.dart`.
- Every new page from this skill must be a `StatefulWidget` with a private state class (`_MyPageState`), even if the first version is simple.
- Before wiring navigation, verify the target page constructor is `const` and has no missing required params.
- Keep app styling on project tokens: use `AppColors` and `AppSpacing` from `lib/theme/`; do not hardcode new color/spacing systems.

## Instructions

1. Choose location, filename, and class names.
   - Place the file at `baller_app/lib/pages/<FeatureName>/<feature_name>_page.dart`.
   - Use `snake_case_page.dart` filenames and `PascalCasePage` class names, matching `lib/pages/Home/home_page.dart` and `lib/pages/Map/map_selection_page.dart`.
   - Use this class structure:
     - `class ExamplePage extends StatefulWidget { const ExamplePage({super.key}); ... }`
     - `class _ExamplePageState extends State<ExamplePage> { ... }`
   - Verify the file path and class name match exactly (folder, filename, widget name) before proceeding to the next step.
   - This step provides the page identity used in Step 2.

2. Add imports and baseline scaffold using existing project conventions.
   - Start with these imports (adjust feature-specific imports as needed):
     - `import 'package:flutter/material.dart';`
     - `import 'package:supabase_flutter/supabase_flutter.dart';`
     - `import 'package:baller_app/theme/app_colors.dart';`
     - `import 'package:baller_app/theme/app_spacing.dart';`
   - Build a `Scaffold` with `backgroundColor: AppColors.background`.
   - Inside `build`, read media size once:
     - `final screenHeight = MediaQuery.of(context).size.height;`
     - `final screenWidth = MediaQuery.of(context).size.width;`
   - Use spacing constants (`AppSpacing.md`, `AppSpacing.lg`) for paddings/sized boxes.
   - Verify the page compiles with only scaffold/layout code before proceeding to the next step.
   - This step uses output from Step 1.

3. Add Supabase data-loading method and state fields.
   - In state, declare data + loading + error fields, then add an async loader called from `initState()`, following patterns from:
     - `lib/pages/Map/map_page.dart` (`fetchCourts`, `setState` updates)
     - `lib/pages/Home/home_page.dart` (`getUserName`, query + error handling)
   - Query style must use:
     - `Supabase.instance.client.from('<table>').select(...)`
   - Wrap query in `try/catch`; on error, set an error string or throw `Exception('...: $e')`.
   - Call loader inside `initState()` after `super.initState();`.
   - Verify data is assigned via `setState` and `mounted` checks are used before UI calls (SnackBar/navigation) before proceeding to the next step.
   - This step uses output from Step 2.

4. Render loading, error, and success UI gates.
   - In `build`, include explicit UI states:
     - Loading: `const CircularProgressIndicator()` centered in scaffold body.
     - Error: `Text('Error: ...')` with `AppColors.textPrimary`/`textSecondary`.
     - Success: main content widgets.
   - If using `FutureBuilder`, follow the same triage used in `lib/pages/Home/home_page.dart` (`waiting` -> spinner, `hasError` -> text, `hasData` -> content).
   - If using local state booleans/lists, match `map_page.dart` style (`isEmpty` fallback, loaded list view).
   - Verify all three states can be reached in code paths before proceeding to the next step.
   - This step uses output from Step 3.

5. Wire navigation from an existing entry point.
   - Use direct navigator wiring (project standard):
     - `Navigator.push(context, MaterialPageRoute(builder: (context) => const ExamplePage()));`
   - Integrate in one of these existing points based on user intent:
     - `lib/pages/Home/home_page.dart` via `NavigationButton`.
     - `lib/pages/Home/main_page.dart` by adding page to `_pages` list if it belongs in bottom tabs.
     - Relevant feature page button/gesture handlers (pattern in `map_page.dart` and `login_page.dart`).
   - Add required imports where navigation is triggered.
   - Verify tapping the wired control opens the new page before proceeding to the next step.
   - This step uses output from Step 1.

6. Run project validation commands from `baller_app/`.
   - Run:
     - `flutter pub get`
     - `flutter analyze`
     - `flutter test`
   - If only one page was added and there are no tests for that area, still run `flutter analyze` at minimum.
   - Verify commands complete without new errors before marking work done.
   - This step uses output from Steps 2-5.

## Examples

### Example 1: Add a map-adjacent page

User says: "Create a new screen for nearby court recommendations."

Actions taken:
1. Created `baller_app/lib/pages/Map/recommended_courts_page.dart` with `RecommendedCourtsPage extends StatefulWidget`.
2. Added imports for `material`, `supabase_flutter`, `app_colors.dart`, and `app_spacing.dart`.
3. Implemented `Future<void> fetchRecommendedCourts()` using `Supabase.instance.client.from('courts').select().eq('status', 'approved')` in `initState()`.
4. Added loading/error/success rendering using spinner and `Text('Error: ...')` branch.
5. Wired navigation from `lib/pages/Map/map_page.dart` with `Navigator.push(... const RecommendedCourtsPage())`.
6. Ran `flutter analyze` and fixed any import/const issues.

Result:
- New page follows the same structure as existing pages (`map_page.dart`, `home_page.dart`), uses project theme tokens, and opens through existing navigator flow.

## Common Issues

- If you see `Target of URI doesn't exist: 'package:baller_app/theme/app_spacing.dart'`:
  1. Verify file exists at `baller_app/lib/theme/app_spacing.dart`.
  2. Verify import uses package path exactly: `import 'package:baller_app/theme/app_spacing.dart';`.
  3. Run `flutter pub get` in `baller_app/` and re-run `flutter analyze`.

- If you see `No user logged in` while loading page data:
  1. Check whether page requires authenticated user (`Supabase.instance.client.auth.currentUser`).
  2. Guard null user before query and show fallback UI or route through `AuthGate` flow in `lib/auth/auth_gate.dart`.
  3. Confirm app starts from `AuthGate` via `lib/main.dart`.

- If you see Supabase query failures like `PostgrestException` or `Error fetching ...`:
  1. Verify table/column names exactly match query (`.from('profiles')`, `.select('username')`, etc.).
  2. Wrap query in `try/catch` and surface `Exception('Error fetching <thing>: $e')` for debugging.
  3. Confirm filters (`.eq('id', user.id)`) match real data types.

- If navigation tap does nothing or fails with constructor errors:
  1. Verify the destination page constructor is `const` or pass required args.
  2. Verify import path for destination page is correct in caller file.
  3. Ensure `Navigator.push(context, MaterialPageRoute(...))` is called inside a valid widget `BuildContext`.

- If analyzer warns about non-const widgets or style drift:
  1. Convert eligible constructors/usages to `const` (project uses many const widgets).
  2. Replace newly introduced hardcoded spacing with `AppSpacing` values.
  3. Replace newly introduced hardcoded palette values with `AppColors` constants where available.

- If `flutter test` fails after page creation with unrelated baseline failures:
  1. Run `flutter analyze` first and fix page/import issues from your changes.
  2. Re-run `flutter test` and isolate failures not touched by this page.
  3. Report baseline failures separately; do not hide new failures from this page work.