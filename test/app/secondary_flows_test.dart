import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/shared/widgets/atoms/rating_circles.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.text('Start my diary'));
    await tester.pumpAndSettle();
  }

  testWidgets('share action opens the share sheet with a link preview', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await tester.tap(find.text('Costa Rica Slow Days'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Share board'));
    await tester.pumpAndSettle();

    expect(find.text('Share board'), findsOneWidget);
    expect(find.text('wanderboard.app/b/costa-rica'), findsOneWidget);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.text('Email draft ready (mock)'), findsOneWidget);
  });

  testWidgets('adding a review saves it and drops it into the board', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.bySemanticsLabel('Add a place'));
    await tester.pumpAndSettle();
    expect(find.text('New place'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Select photo').first);
    await tester.enterText(
      find.widgetWithText(TextField, 'Place name'),
      'Volcán Poás',
    );
    await tester.enterText(find.widgetWithText(TextField, 'City'), 'Alajuela');
    await tester.tap(find.byType(RatingCircle).at(4));
    final form = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Coffee Corners'),
      200,
      scrollable: form,
    );
    await tester.ensureVisible(find.text('Coffee Corners'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coffee Corners'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Save to diary'),
      200,
      scrollable: form,
    );
    await tester.ensureVisible(find.text('Save to diary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to diary'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Saved to your diary'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Volcán Poás'), findsOneWidget);
  });
}
