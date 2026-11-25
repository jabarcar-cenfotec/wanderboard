import 'package:flutter/material.dart';

import 'app/wanderboard_app.dart';
import 'features/privacy/application/demo_role.dart';
import 'features/privacy/data/http_e2ee_backend.dart';

/// Local E2EE demo backend (see backend/README.md). Override with
/// --dart-define=E2EE_SERVER=http://host:port/
const _serverUrl = String.fromEnvironment(
  'E2EE_SERVER',
  defaultValue: 'http://localhost:8080/',
);

void main() {
  final backend = HttpE2eeBackend(Uri.parse(_serverUrl));
  // ?rol=emisor and ?rol=sofia open the two phones of the sharing demo.
  final role = DemoRole.parse(Uri.base.queryParameters['rol']);
  runApp(
    WanderboardApp(backend: backend, adminUrl: backend.adminUrl, role: role),
  );
}
