import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> signIn(WidgetTester tester) => enterDiary(tester);

  testWidgets('share action opens the share sheet with a link preview', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);
    await tester.tap(find.text('Costa Rica sin prisa'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Compartir colección'));
    await tester.pumpAndSettle();

    expect(find.text('Compartir colección'), findsOneWidget);
    expect(find.text('spotly.app/b/costa-rica'), findsOneWidget);

    await tester.tap(find.text('Correo'));
    await tester.pumpAndSettle();
    expect(find.text('Borrador de correo listo (simulado)'), findsOneWidget);
  });
}
