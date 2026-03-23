# Model Rules

Models must:

- Be immutable when possible (final fields, const constructors where applicable)
- Include `fromJson` and `toJson` for serialization
- Contain NO business logic (no API calls, no validation beyond parsing)
- Use null safety; prefer nullable types over dynamic

Keep models in `lib/models/`. One file per model when practical.
And create folders and classify models based on what they are. Seperate them in Groups
