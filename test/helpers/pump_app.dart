import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/app/wanderboard_app.dart';
import 'package:wanderboard/core/theme/app_theme.dart';
import 'package:wanderboard/core/theme/wander_typography.dart';

/// Font resolver that never touches the network, so tests stay hermetic.
const testFonts = PlainFontResolver();

/// Theme used by isolated widget tests.
ThemeData testTheme() => AppTheme.light(fonts: testFonts);

/// Pumps the full app with deterministic, offline-friendly configuration.
Future<void> pumpWanderApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const WanderboardApp(fonts: testFonts));
  await tester.pumpAndSettle();
}

/// Wraps a single widget with the Wanderboard theme.
Widget themed(Widget child) {
  return MaterialApp(
    theme: testTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}
