import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/data/seed_places.dart';
import 'package:wanderboard/features/privacy/application/demo_role.dart';
import 'package:wanderboard/features/privacy/application/e2ee_device.dart';
import 'package:wanderboard/features/privacy/data/e2ee_cipher.dart';
import 'package:wanderboard/features/privacy/data/in_memory_e2ee_backend.dart';
import 'package:wanderboard/features/privacy/domain/e2ee_errors.dart';

/// Two-phone demo: what a recipient learns from the backend inbox.
void main() {
  final cipher = E2eeCipher(recoveryIterations: 1000);
  final place = seedPlaces.first;
  late InMemoryE2eeBackend server;
  late E2eeDevice sender;
  late E2eeDevice sofia;
  late E2eeDevice intruder;

  setUp(() async {
    server = InMemoryE2eeBackend();
    sender = E2eeDevice(accountId: 'sender', server: server, cipher: cipher);
    sofia = E2eeDevice(
      accountId: DemoRole.remoteGuestId,
      server: server,
      cipher: cipher,
    );
    intruder = E2eeDevice(accountId: 'intruder', server: server, cipher: cipher);
    await Future.wait([sender.ready, sofia.ready, intruder.ready]);
  });

  Future<void> share() => sender.shareCollection(
    collectionId: 'col-1',
    title: 'Rincones de café',
    places: [place],
    recipientIds: [DemoRole.remoteGuestId],
    includeNotes: false,
  );

  test('the recipient sees the share, opens it and others see nothing', () async {
    await share();

    final inbox = await server.inboxOf(DemoRole.remoteGuestId);
    expect(inbox.single.collectionId, 'col-1');
    expect(inbox.single.ownerId, 'sender');
    expect(inbox.single.keyId, isNotEmpty);
    final content = await sofia.openCollection(inbox.single.collectionId);
    expect(content.title, 'Rincones de café');
    expect(content.places.single.name, place.name);

    expect(await server.inboxOf('sender'), isEmpty);
    expect(await server.inboxOf('intruder'), isEmpty);
    await expectLater(
      intruder.openCollection('col-1'),
      throwsA(isA<E2eeAccessDenied>()),
    );
  });

  test('revoking removes the share from the inbox', () async {
    await share();

    await sender.revokeAccess('col-1', DemoRole.remoteGuestId);

    expect(await server.inboxOf(DemoRole.remoteGuestId), isEmpty);
    await expectLater(
      sofia.openCollection('col-1'),
      throwsA(isA<E2eeAccessDenied>()),
    );
  });

  test('DemoRole.parse maps the rol parameter', () {
    expect(DemoRole.parse('emisor'), DemoRole.sender);
    expect(DemoRole.parse('sofia'), DemoRole.recipient);
    expect(DemoRole.parse(null), DemoRole.standalone);
    expect(DemoRole.parse('otro'), DemoRole.standalone);
  });
}
