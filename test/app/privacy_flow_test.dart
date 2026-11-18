import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/app/wanderboard_app.dart';
import 'package:wanderboard/features/privacy/data/e2ee_cipher.dart';
import 'package:wanderboard/features/privacy/presentation/privacy_screen.dart';

import '../helpers/pump_app.dart';

/// E2EE proof of concept (research project): scenarios E2E-01..E2E-03.
void main() {
  Future<void> openPrivacy(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      WanderboardApp(
        fonts: testFonts,
        cipher: E2eeCipher(recoveryIterations: 1000),
      ),
    );
    await tester.pumpAndSettle();
    await enterDiary(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacidad y cifrado'));
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    final target = find.text(label);
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: find
          .descendant(
            of: find.byType(PrivacyScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('E2E-01 the diary is synced encrypted; the server view has '
      'no clear notes', (tester) async {
    await openPrivacy(tester);

    expect(find.textContaining('lugares cifrados en el servidor'), findsOne);
    expect(find.text('0 lugares cifrados en el servidor'), findsNothing);

    await tester.tap(find.text('Ver lo que guarda el servidor'));
    await tester.pumpAndSettle();

    expect(find.text('Vista del servidor'), findsOne);
    expect(find.textContaining('cipherText'), findsWidgets);
    expect(find.textContaining('zapatos para barro'), findsNothing);
  });

  testWidgets('E2E-02 share with Sofía, block an unauthorized account, '
      'then revoke', (tester) async {
    await openPrivacy(tester);

    await tapButton(tester, 'Rincones de café');
    await tapButton(tester, 'Compartir con Sofía');
    expect(find.text('«Rincones de café» compartida con Sofía.'), findsOne);

    await tapButton(tester, 'Abrir como Sofía');
    expect(find.text('Sofía descifró «Rincones de café»'), findsOne);
    expect(find.textContaining('(sin nota)'), findsWidgets);

    await tapButton(tester, 'Abrir como cuenta no autorizada');
    expect(
      find.text('La cuenta no autorizada no puede abrir la colección'),
      findsOne,
    );

    await tapButton(tester, 'Revocar acceso de Sofía');
    expect(find.text('Acceso de Sofía revocado.'), findsOne);
    await tapButton(tester, 'Abrir como Sofía');
    expect(find.text('Sofía no puede abrir la colección'), findsOne);
  });

  testWidgets('E2E-03 recovery works with the phrase and fails without it', (
    tester,
  ) async {
    await openPrivacy(tester);

    await tapButton(tester, 'Crear frase de recuperación');
    final phrase = tester
        .widget<SelectableText>(find.byKey(const Key('recovery-phrase')))
        .data!;

    await tester.enterText(
      find.widgetWithText(TextField, 'Frase en el teléfono nuevo'),
      'AAAA-BBBB-CCCC-DDDD-EEEE-FFFF',
    );
    await tapButton(tester, 'Recuperar en un teléfono nuevo');
    expect(find.text('Frase incorrecta'), findsOne);

    await tester.enterText(
      find.widgetWithText(TextField, 'Frase en el teléfono nuevo'),
      phrase,
    );
    await tapButton(tester, 'Recuperar en un teléfono nuevo');
    expect(find.textContaining('lugares recuperados'), findsOne);
  });
}
