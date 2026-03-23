# Supabase Rules

All Supabase access goes through:

- `lib/supabase/` (e.g. court_services, auth-related clients)
- or `lib/services/` when wrapping Supabase calls

Never:

- Query Supabase directly from UI (pages/widgets)
- Expose service role key or admin privileges in client code
- Tie the app tightly to supabase so I can switch later to a self hosted backend

Always:

- Filter by `auth.uid()` where data is user-scoped
- Respect RLS (Row Level Security) policies; assume RLS is enabled

---

## Access Architecture

- UI layers must call services/repositories only
- Supabase clients must not be instantiated inside widgets
- Centralize Supabase client configuration in one location
- Reuse shared query helpers when possible

---

## Ownership & Authorization

- Inserts must automatically bind ownership using authenticated user id
- Never accept owner/user_id from UI input
- Updates and deletes must verify ownership through RLS-compatible filters
- Assume client-side filtering is NOT security

---

## Query Safety

- Avoid broad `select()` queries; request only required columns
- Never use unrestricted table reads
- Pagination must be used for list endpoints
- Limit result size where applicable

---

## Error Handling

- Always handle Supabase errors explicitly
- Never ignore `error` responses
- Convert backend errors into safe domain errors before UI exposure
- Do not expose raw database messages to users

---

## Data Mapping

- Map Supabase responses into typed models
- Avoid passing raw JSON/maps into UI
- Validate nullable fields before usage

---

## Async & State Safety

- Prevent duplicate requests from rapid UI actions
- Cancel subscriptions when no longer needed
- Avoid race conditions between auth state and queries

---

## Security Guarantees

- RLS policies are the source of truth for authorization
- Frontend checks are UX improvements, not security
- Assume all client requests can be modified by attackers

---

## AI Enforcement Rules

The AI must:

- Never move Supabase queries into UI code during refactoring
- Preserve service-layer abstraction
- Warn when queries bypass ownership filtering
- Prefer repository/service patterns over inline queries

---

## Testing (TDD Integration)

- Supabase services must have unit tests
- Unauthorized access scenarios must be tested
- Mock Supabase responses instead of calling live backend
