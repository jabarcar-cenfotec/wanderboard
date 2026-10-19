import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/presentation/place_detail_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.text('Start my diary'));
    await tester.pumpAndSettle();
  }

  Future<void> openBoard(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(find.text(name), 200);
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  testWidgets('app boots into onboarding', (tester) async {
    await pumpWanderApp(tester);

    expect(find.text('Your private diary of places'), findsOneWidget);
    expect(find.text('Start my diary'), findsOneWidget);
  });

  testWidgets('signing in lands on Home with the boards', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    expect(find.text('My boards'), findsOneWidget);
    expect(find.text('Costa Rica Slow Days'), findsOneWidget);
  });

  testWidgets('tapping a board shows its places', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await openBoard(tester, 'Costa Rica Slow Days');

    expect(find.text('Arenal Hanging Bridges'), findsOneWidget);
    expect(find.text('Monteverde Cloud Forest'), findsOneWidget);
  });

  testWidgets('tapping a place opens its private review', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await openBoard(tester, 'Costa Rica Slow Days');

    await tester.ensureVisible(find.text('Arenal Hanging Bridges'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arenal Hanging Bridges'));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailScreen), findsOneWidget);
    expect(find.text('My private note'), findsOneWidget);
  });

  testWidgets('bottom nav opens Profile with stat circles', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('places'), findsOneWidget);
    expect(find.text('boards'), findsOneWidget);
    expect(find.text('cities'), findsOneWidget);
  });
}
