# Architecture Rules

Structure:

- **auth** → authentication only
- **models** → pure data models (no business logic)
- **pages** → UI only, no direct backend calls
- **services** → business logic, API calls, validation
- **widgets** → reusable UI components
- **theme** → colors, spacing, typography
- **supabase** → Supabase client usage (queries, inserts); called from services or pages via services

NEVER:

- Call backend or Supabase directly from pages or widgets
- Put business logic inside widgets
- Mix UI and database logic in the same layer

Rule priority: lower number wins when rules conflict (see 00_global_rules).
