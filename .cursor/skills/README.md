# BallerApp Cursor AI Skills

This folder contains **production-level AI skills** that make the Cursor assistant more effective, consistent, and intelligent when working on the BallerApp project (Flutter + Supabase, court discovery, pickup basketball).

Each skill defines a **role**, **expertise**, **responsibilities**, **rules**, **best practices**, **anti-patterns**, and **decision guidelines** so the AI behaves like a specialized engineer or domain expert within this codebase.

---

## Purpose of Each Skill

| Skill                               | Purpose                                                                                                                                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **project_manager**                 | Keeps structure (code + `.cursor` docs), plans before coding, prioritizes work, tracks progress, and enforces post-change workflow (changelog, prompt history, security checklist).              |
| **pickup_basketball_domain_expert** | Brings pickup basketball culture into design: peak times, skill level, rotation, crowding, court popularity. Ensures features help players find courts and join games quickly.                   |
| **security_engineer**               | Ensures input validation, no secrets in code, Supabase RLS, auth from session only, safe async and logging. Runs security checklist after changes.                                               |
| **flutter_architect**               | Enforces BallerApp structure: pages/widgets = UI only, services = logic/API, models = data only. Prevents monolithic widgets and unnecessary rebuilds.                                           |
| **flutter_mobile_architect**        | Applies clean architecture, repository pattern, feature-first organization, and mobile lifecycle on top of Flutter structure. Focus on testability and mobile-specific concerns.                 |
| **api_integrations_expert**         | Designs and implements REST/Supabase integrations: reusable services, retries, caching, rate limiting, pagination, error handling, and API cost control.                                         |
| **sports_court_data_expert**        | Defines and uses court metadata (indoor/outdoor, surface, lighting, crowd, skill level, pickup likelihood, availability). Keeps data models and filters aligned with player needs.               |
| **maps_engineer**                   | Owns map and geo: Google Maps, geolocation, nearby search, markers, distance (Haversine), caching, API cost, and mobile performance for map features.                                            |
| **performance_optimizer**           | Detects and fixes rebuild loops, heavy widgets, and unnecessary API calls. Promotes const, lazy lists, caching, and disposal.                                                                    |
| **startup_builder**                 | Favors fast iteration and minimal complexity. Chooses simple, shippable solutions and extensible architecture only where clearly needed.                                                         |
| **backend_engineer**                | Backend boundaries and portability: Supabase as current implementation behind services/repositories; avoid coupling UI to provider types; eases a future move to self-hosted or another backend. |

---

## When Cursor Should Rely on Them

- **Planning / prioritization / structure / docs** → **project_manager**
- **Court discovery, filters, “join game,” peak times, skill level, rotation** → **pickup_basketball_domain_expert**
- **Auth, validation, secrets, RLS, logging, security review** → **security_engineer**
- **Where code lives (pages vs services vs models), separation of UI and logic, rebuilds** → **flutter_architect**
- **Clean architecture, repositories, feature structure, lifecycle, platform integration** → **flutter_mobile_architect**
- **New or changed APIs, retries, caching, rate limits, pagination, errors** → **api_integrations_expert**
- **Court attributes, metadata, filters, data models for courts** → **sports_court_data_expert**
- **Map UI, geolocation, “near me,” markers, distance, map/geo API cost** → **maps_engineer**
- **Jank, slow lists, too many rebuilds or API calls** → **performance_optimizer**
- **“Keep it simple,” “ship fast,” scope of features, avoid over-engineering** → **startup_builder**
- **Data/auth layer design, Supabase behind abstractions, future self-hosted backend** → **backend_engineer**

Cursor uses skill **descriptions and sections** to decide when to apply each skill; the more specific the user request (e.g. “add court filters,” “fix map performance”), the more likely the relevant skill is applied.

---

## How Skills Interact

- **project_manager** sets the workflow (plan → code → changelog, prompt history, security checklist) and keeps `.cursor` and code structure consistent. Other skills should respect this workflow.
- **flutter_architect** and **flutter_mobile_architect** define _where_ code goes (pages/services/models) and _how_ Flutter is structured. **api_integrations_expert**, **maps_engineer**, and **security_engineer** assume API/map/auth code lives in services and never in pages/widgets.
- **security_engineer** is cross-cutting: every skill that touches auth, input, secrets, or persistence should align with it (no keys in code, validate input, RLS).
- **pickup_basketball_domain_expert** and **sports_court_data_expert** inform _what_ court data and UX to build; **maps_engineer** and **api_integrations_expert** implement the technical side (map, APIs, caching). **performance_optimizer** applies when implementing those features (lists, rebuilds, API calls).
- **startup_builder** moderates scope and complexity: when **flutter_mobile_architect** or **api_integrations_expert** suggest more abstraction, **startup_builder** can favor the simpler option that still ships and stays maintainable.
- **backend_engineer** applies to persistence/auth **seams** and provider swap; it should not override **security_engineer** or **07_supabase_rules** (RLS, secrets). It complements **api_integrations_expert** (resilience, caching) rather than duplicating it.
- **Conflicts** (e.g. “full clean architecture” vs “ship minimal”): prefer the option that satisfies **security_engineer** and **project_manager** first, then balance the rest (e.g. **startup_builder** vs **flutter_mobile_architect**) by documenting the trade-off and staying consistent with `.cursor/rules/` and `project_context.md`.

---

## Project References

- **Architecture and conventions:** `.cursor/ai/context/project_context.md`
- **Tech stack:** `.cursor/project/tech_stack.md`
- **Rules (00–11):** `.cursor/rules/` (lower number wins on conflict)
- **After coding:** Update `.cursor/ai/changes/changelog.md`, append `.cursor/ai/prompts/prompt_history.md`, run `.cursor/ai/security/security_checks.md`

These skills are **specific to BallerApp** and are intended for use with this project’s Flutter + Supabase + maps + court-data setup.
