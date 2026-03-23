# Backend abstraction & portability rules

**Scope:** Data access boundaries, provider swap, and long-term backend flexibility.  
**Does not replace:** `00_global_rules`, `06_security_rules`, or `07_supabase_rules` (RLS, auth, and Supabase-specific safety stay authoritative there). On conflict, **lower-numbered rules win**.

---

## Current stack

- **Supabase** is the **current** backend (Postgres, Auth, and related products as used in this project).
- App code should treat it as an **implementation behind** services/repositories, not as the definition of the whole app architecture.

---

## Portability (future self-hosted or other backend)

- **No Supabase types or raw API shapes in UI:** Pages and widgets consume domain models and app-level results only; map Supabase responses inside `lib/services/`, `lib/supabase/`, or repository adapters.
- **Stable seams:** Prefer interfaces or clear service APIs for persistence and auth (“who is signed in,” “load courts,” “save profile”) so a different backend can implement the same contract later.
- **Centralize provider specifics:** One place configures the Supabase client; avoid scattering PostgREST/Supabase-only patterns across features.
- **Auth identity:** Services depend on a single notion of authenticated user (e.g. user id from session), not on Supabase SDK types propagating upward.
- **Optional capabilities:** Realtime, Storage, Edge Functions—if used—should sit behind dedicated service wrappers so they can be reimplemented or dropped without rewriting UI.

---

## What “not over-defining on Supabase” means here

- Domain naming and models reflect **the product** (courts, games, users), not table names or RPC names as the only vocabulary in business logic.
- Avoid baking in assumptions that only Supabase provides unless necessary; when necessary, **isolate** them in the adapter layer.

---

## AI behavior

- When adding features, **extend services/repositories** rather than growing Supabase calls in UI.
- When refactoring, **preserve** abstraction boundaries that would ease a later move to self-hosted APIs or another BaaS.
- Do not weaken `07_supabase_rules` (RLS, `auth.uid()`, no service role in client) for convenience.
