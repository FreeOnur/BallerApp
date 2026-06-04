# baller_app (Flutter)

## Run (legacy Supabase — default)

```powershell
flutter run `
  --dart-define=USE_LEGACY_SUPABASE=true `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Run (self-hosted API)

Start backend first (`../backend/README.md`), then:

```powershell
flutter run `
  --dart-define=USE_LEGACY_SUPABASE=false `
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Physical device: use your PC LAN IP instead of `10.0.2.2`.

## Security

Do not commit Supabase keys or API secrets. Use dart-define or CI secrets only.
