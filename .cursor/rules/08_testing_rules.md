# Testing Rules

When adding or changing logic:

- **Suggest** unit tests for new service or business logic; do not auto-generate tests unless the user asks.
- **Test** - test every feature before you implement the features or after but a test for every feature is a must. 
- **Test service layer first** — services and Supabase wrappers are the best candidates for unit tests.
- **Avoid UI/widget tests unless necessary** — prefer logic tests over fragile widget tests.
- **Guidance only** — point to test files or patterns (e.g. `test/` folder, `flutter_test`); do not create full test suites without being asked.

Testing foundation: ensure `test/` exists; document in project_context if test structure is added.
w