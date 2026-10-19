import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/presentation/place_detail_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.text('Empezar mi diario'));
    await tester.pumpAndSettle();
  }

  Future<void> openBoard(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(
      find.text(name),
      200,
      scrollable: verticalScroll(),
    );
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  testWidgets('app boots into onboarding', (tester) async {
    await pumpWanderApp(tester);

    expect(find.text('Tu diario privado de lugares'), findsOneWidget);
    expect(find.text('Empezar mi diario'), findsOneWidget);
  });

  testWidgets('signing in lands on Mis lugares with the collections', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    expect(find.text('Mis lugares'), findsWidgets);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Costa Rica sin prisa'), findsOneWidget);
  });

  testWidgets('tapping a collection shows its places', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await openBoard(tester, 'Costa Rica sin prisa');

    expect(find.text('Puentes Colgantes del Arenal'), findsOneWidget);
    expect(find.text('Bosque Nuboso de Monteverde'), findsOneWidget);
  });

  testWidgets('tapping a place opens its private note', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await openBoard(tester, 'Costa Rica sin prisa');

    await tester.ensureVisible(find.text('Puentes Colgantes del Arenal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puentes Colgantes del Arenal'));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailScreen), findsOneWidget);
    expect(find.text('Mi nota privada'), findsOneWidget);
  });

  testWidgets('bottom nav opens Perfil with stat circles', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('lugares'), findsOneWidget);
    expect(find.text('colecciones'), findsOneWidget);
    expect(find.text('ciudades'), findsOneWidget);
  });
}
