import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/app/wanderboard_app.dart';
import 'package:wanderboard/features/places/data/seed_places.dart';
import 'package:wanderboard/features/privacy/application/demo_role.dart';
import 'package:wanderboard/features/privacy/application/e2ee_device.dart';
import 'package:wanderboard/features/privacy/data/e2ee_cipher.dart';
import 'package:wanderboard/features/privacy/data/in_memory_e2ee_backend.dart';
import 'package:wanderboard/features/privacy/presentation/privacy_screen.dart';

import '../../helpers/pump_app.dart';

/// Two app instances sharing one backend: the sender phone and Sofía's.
void main() {
  final cipher = E2eeCipher(recoveryIterations: 1000);
  late InMemoryE2eeBackend backend;

  setUp(() => backend = InMemoryE2eeBackend());

  Future<void> pump(WidgetTester tester, DemoRole role) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      WanderboardApp(
        fonts: testFonts,
        cipher: cipher,
        backend: backend,
        role: role,
        pollInterval: const Duration(seconds: 2),
      ),
    );
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

  Future<void> openPrivacy(WidgetTester tester) async {
    await enterDiary(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacidad y cifrado'));
    await tester.pumpAndSettle();
  }

  testWidgets('rol=sofia boots into her phone, shows the notification and '
      'opens the collection', (tester) async {
    await pump(tester, DemoRole.recipient);
    expect(find.text('Teléfono de Sofía'), findsOne);
    expect(find.text('Esperando que te compartan algo…'), findsOne);
    expect(find.text('Empezar mi diario'), findsNothing);
    expect(await backend.publicKeyOf(DemoRole.remoteGuestId), isNotNull);

    final sender = E2eeDevice(
      accountId: 'sender',
      server: backend,
      cipher: cipher,
    );
    await sender.shareCollection(
      collectionId: 'col-1',
      title: 'Rincones de café',
      places: [seedPlaces.first],
      recipientIds: [DemoRole.remoteGuestId],
      includeNotes: false,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Te compartieron una colección'), findsOne);
    expect(find.text('Esperando que te compartan algo…'), findsNothing);
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('«Rincones de café»'), findsOne);
    expect(find.textContaining(seedPlaces.first.name), findsOne);

    await sender.revokeAccess('col-1', DemoRole.remoteGuestId);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Ya no tienes acceso a esta colección.'), findsOne);
    expect(find.text('«Rincones de café»'), findsNothing);
  });

  testWidgets('rol=emisor says Sofía is not connected until her key '
      'exists, then shares with her phone', (tester) async {
    await pump(tester, DemoRole.sender);
    await openPrivacy(tester);

    await tapButton(tester, 'Compartir con Sofía');
    expect(find.text('El teléfono de Sofía aún no está conectado.'), findsOne);
    expect(find.textContaining('compartida con Sofía'), findsNothing);

    final sofia = E2eeDevice(
      accountId: DemoRole.remoteGuestId,
      server: backend,
      cipher: cipher,
    );
    await sofia.ready;
    await tapButton(tester, 'Compartir con Sofía');

    expect(find.textContaining('compartida con Sofía.'), findsOne);
    expect(find.text('Abrir como Sofía'), findsNothing);
    expect(find.text('Sofía la abre en su propio teléfono.'), findsOne);
    expect((await backend.inboxOf(DemoRole.remoteGuestId)).length, 1);

    await tapButton(tester, 'Abrir como cuenta no autorizada');
    expect(
      find.text('La cuenta no autorizada no puede abrir la colección'),
      findsOne,
    );
    await tapButton(tester, 'Revocar acceso de Sofía');
    expect(find.text('Acceso de Sofía revocado.'), findsOne);
    expect(await backend.inboxOf(DemoRole.remoteGuestId), isEmpty);
  });
}
