# Security First Rules

Security has higher priority than feature speed.
The AI must prefer secure implementations over faster or simpler ones.
Existing secure code must NEVER be removed unless explicitly instructed.

---

## Authentication

- Never trust client input; validate on client and rely on server/RLS for enforcement
- Use authenticated user id only from Supabase session (e.g. `Supabase.instance.client.auth.currentUser`)
- Do not pass user ids from UI; derive from session in services

### Additional Rules
- Always verify authentication state before protected operations
- Treat missing session as unauthorized access
- Never cache auth-sensitive decisions permanently on client
- Re-check authorization for every write operation
- Logout must clear sensitive memory/state

---

## Input Validation

- Validate and sanitize all user inputs before sending to backend or storing
- Reject empty/whitespace-only strings where content is required
- Use allowlists for enums and known values; avoid raw string injection
- Make it SQL Injection and XSS proof.

### Additional Rules
- Escape or sanitize all user-generated text rendered in UI
- Never interpolate raw user input into queries or filters
- Prefer typed models over dynamic maps
- Validate length limits for text inputs
- Normalize input (trim, lowercase where applicable)

---

## Safe Async Handling

- Never swallow errors; always handle Future/Stream errors (try/catch or .catchError)
- Do not expose stack traces or internal errors to the UI in production
- Timeout long-running operations where appropriate

### Additional Rules
- Fail safely: partial failures must not corrupt data
- Retry only idempotent operations
- Cancel subscriptions/streams when widgets dispose
- Prevent duplicate async submissions (double taps)

---

## Supabase & RLS

- Never expose service role key in client code
- Assume RLS is enabled; all queries must respect Row Level Security
- Filter by `auth.uid()` for user-owned data; do not bypass RLS

### Additional Rules
- Never simulate authorization on client only
- All inserts must automatically bind ownership to `auth.uid()`
- Avoid broad SELECT queries without ownership filters
- Prefer database policies over frontend checks
- Do not trust filtered client lists as authorization proof

---

## Data Safety

- Sanitize inputs; prevent null crashes; validate forms before requests
- Do not log PII, tokens, or full request/response bodies (see 09_logging_rules)

### Additional Rules
- Apply defensive null checking for all external data
- Treat backend responses as untrusted input
- Avoid overfetching sensitive columns
- Use minimal required data fields only
- Protect location or profile data with least exposure principle

---

## Secrets

- No API keys, anon keys, or secrets hardcoded in source; use env/flutter_dotenv or build-time config
- Do not commit `.env` or files containing secrets

### Additional Rules
- Never print environment variables to logs
- Rotate keys if accidental exposure is detected
- Separate development and production configs
- Secrets must never appear in tests or mock data

---

## Networking

- HTTPS only; no plain HTTP for API or auth
- No raw tokens or credentials in logs or error messages

### Additional Rules
- Validate server responses before usage
- Handle network failures gracefully
- Use secure headers where applicable
- Prevent repeated rapid requests (basic rate protection)

---

## Secure Coding Behaviour (AI Enforcement)

The AI must:

- Preserve existing security checks when modifying code
- Never remove validation, auth checks, or guards unless explicitly requested
- Warn if a requested change weakens security
- Prefer least-privilege data access
- Propose safer alternatives when insecure patterns are detected

---

## TDD Security Integration

When using Test Driven Development:

- Acceptance criteria involving security must have tests
- Authentication failures must be testable scenarios
- Unauthorized access must be tested explicitly
- Validation rules must include negative test cases

---

## Default Security Mindset

Assume:
- Client input is malicious
- Network is unreliable
- Users may attempt unintended access
- Backend responses may be malformed

Design defensively by default.