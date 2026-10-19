import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/app/device_frame.dart';

import '../helpers/pump_app.dart';

void main() {
  late Size reportedSize;
  late EdgeInsets reportedPadding;

  Future<void> pumpFramed(
    WidgetTester tester, {
    required Size viewport,
    bool enabled = true,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme(),
        builder: (context, child) =>
            DeviceFrame(enabled: enabled, child: child!),
        home: Builder(
          builder: (context) {
            reportedSize = MediaQuery.sizeOf(context);
            reportedPadding = MediaQuery.paddingOf(context);
            return const SizedBox.expand();
          },
        ),
      ),
    );
  }

  testWidgets('wide viewport renders the app inside a phone-sized screen', (
    tester,
  ) async {
    await pumpFramed(tester, viewport: const Size(1440, 900));

    expect(reportedSize, DeviceFrame.screenSize);
    expect(reportedPadding.top, greaterThan(0));
    expect(reportedPadding.bottom, greaterThan(0));
    expect(find.byKey(DeviceFrame.bezelKey), findsOneWidget);
  });

  testWidgets('short viewport scales the phone down instead of clipping', (
    tester,
  ) async {
    await pumpFramed(tester, viewport: const Size(1280, 600));

    expect(reportedSize, DeviceFrame.screenSize);
    final bezel = tester.getSize(find.byKey(DeviceFrame.bezelKey));
    final rendered = tester.getRect(find.byKey(DeviceFrame.bezelKey));
    expect(rendered.height, lessThanOrEqualTo(600));
    expect(bezel.height, greaterThan(DeviceFrame.screenSize.height));
  });

  testWidgets('narrow viewport (a real phone) passes through untouched', (
    tester,
  ) async {
    await pumpFramed(tester, viewport: const Size(400, 800));

    expect(reportedSize, const Size(400, 800));
    expect(find.byKey(DeviceFrame.bezelKey), findsNothing);
  });

  testWidgets('disabled frame passes through on any viewport', (tester) async {
    await pumpFramed(tester, viewport: const Size(1440, 900), enabled: false);

    expect(reportedSize, const Size(1440, 900));
    expect(find.byKey(DeviceFrame.bezelKey), findsNothing);
  });
}
