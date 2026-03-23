# Performance Rules

Avoid:

- unnecessary rebuilds
- heavy logic in build()
- repeated API calls

Prefer:

- caching
- pagination

---

## Widget Performance

- Keep `build()` methods pure and fast
- Do not execute async calls inside `build()`
- Move logic to services, controllers, or providers
- Split large widgets into smaller reusable widgets
- Use const constructors where possible
- Avoid rebuilding entire screens when only small parts change

---

## State Management

- Update only the minimal required state
- Avoid global rebuild triggers
- Prefer scoped state updates over full tree refresh
- Do not call setState unnecessarily
- Debounce rapid UI-triggered updates

---

## Network & Supabase Calls

- Fetch data once and reuse results when possible
- Cache frequently accessed data
- Use pagination or limits for list queries
- Avoid duplicate simultaneous requests
- Do not refetch unchanged data on navigation rebuilds

---

## Async & Lifecycle Safety

- Load data in initState(), controllers, or providers — not build()
- Cancel streams/subscriptions when widgets dispose
- Prevent multiple concurrent fetches for same resource
- Use loading guards to avoid duplicate calls

---

## Rendering Optimization

- Use ListView.builder for large lists
- Avoid large widget trees inside scrolling widgets
- Lazy-load images and heavy content
- Avoid expensive layout calculations per frame

---

## Data Handling

- Request only required fields from backend
- Avoid large payload transfers
- Transform data once, reuse results
- Prefer immutable models when possible

---

## AI Enforcement Rules

The AI must:

- Never introduce API calls inside build()
- Prefer minimal rebuild scope
- Detect and prevent duplicate network calls
- Suggest pagination for growing datasets
- Warn when performance risks are introduced

---

## Performance Targets (Guidelines)

- UI interactions should feel instant (<100ms perceived delay)
- Initial data loads should be minimized
- Lists must support scalable growth without full reloads

---

## TDD Performance Integration

- Performance-sensitive features should include tests or checks
- Avoid regressions that increase rebuild count
- Prefer measurable improvements over assumptions