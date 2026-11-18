# Local E2EE demo backend

Separate process that stores what the Wanderboard app sends: ciphertext,
nonces, public keys and wrapped keys. It has no key to decrypt anything.

## Run the demo

```bash
# 1. Backend (terminal 1)
cd backend
dart run bin/server.dart          # port 8080, data in backend/data.json

# 2. App (terminal 2), from the wanderboard folder
flutter run -d edge               # or: flutter build web, then serve build/web
```

- Admin panel: http://localhost:8080/admin (tables, raw JSON, clear-text search, reset)
- Flow diagrams for the presentation: http://localhost:8080/admin/flujo (step by step with the arrow keys)
- Data file: `backend/data.json`
- Other server URL: `flutter run --dart-define=E2EE_SERVER=http://host:port/`

Each app launch creates new in-memory keys, so its accounts get a new
suffix (for example `mi-cuenta-pEdt`). Use "Vaciar datos" in the panel to
start clean.
