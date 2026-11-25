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
- Presentation deck: http://localhost:8080/admin/flujo (arrow keys or autoplay, `F` for full screen, keys `1`-`9` switch sections)
- "Dos teléfonos" tab: simulates two phones. Ana (sender) and Sofía (receiver) each run the app in an iframe
  from http://localhost:8097/ with `?rol=emisor` and `?rol=sofia`, with the server's live view and an event timeline in the middle.
  Override the URLs with `?appA=<url>` and `?appB=<url>`.
- Live demo tab ("Demo en vivo"): the real app on the left, what the server stores on the right.
  It embeds the app from http://localhost:8097/ (change with `?app=<url>`):

  ```bash
  flutter build web --release --output=build/web_demo
  python -m http.server 8097 --directory build/web_demo
  ```
- Data file: `backend/data.json`
- Other server URL: `flutter run --dart-define=E2EE_SERVER=http://host:port/`

Each app launch creates new in-memory keys, so its accounts get a new
suffix (for example `mi-cuenta-pEdt`). Use "Vaciar datos" in the panel to
start clean.
