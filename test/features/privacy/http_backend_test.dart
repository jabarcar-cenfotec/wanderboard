import 'dart:io';

import 'package:e2ee_backend/e2ee_api.dart';
import 'package:e2ee_backend/e2ee_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as io;
import 'package:wanderboard/features/places/data/seed_places.dart';
import 'package:wanderboard/features/privacy/application/e2ee_device.dart';
import 'package:wanderboard/features/privacy/data/e2ee_cipher.dart';
import 'package:wanderboard/features/privacy/data/http_e2ee_backend.dart';
import 'package:wanderboard/features/privacy/domain/e2ee_errors.dart';

/// The app against the real local server (backend/) over HTTP: the data
/// file on disk must hold no clear text.
void main() {
  final cipher = E2eeCipher(recoveryIterations: 1000);
  const secretNote = 'Pedir el queque de zanahoria, mesa junto a la ventana';
  final place = seedPlaces.first.copyWith(note: secretNote);

  late Directory dir;
  late File dataFile;
  late HttpServer server;
  late HttpE2eeBackend backend;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('e2ee-backend-test');
    dataFile = File('${dir.path}/data.json');
    server = await io.serve(
      e2eeApi(E2eeStore(file: dataFile)),
      InternetAddress.loopbackIPv4,
      0,
    );
    backend = HttpE2eeBackend(Uri.parse('http://localhost:${server.port}/'));
  });

  tearDown(() async {
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  test('diary, sharing and recovery work over HTTP with only ciphertext '
      'on disk', () async {
    final owner = E2eeDevice(accountId: 'me', server: backend, cipher: cipher);
    final guest = E2eeDevice(
      accountId: 'guest',
      server: backend,
      cipher: cipher,
    );
    final intruder = E2eeDevice(
      accountId: 'intruder',
      server: backend,
      cipher: cipher,
    );

    await owner.uploadPlace(place);
    await guest.ready;
    await intruder.ready;
    await owner.shareCollection(
      collectionId: 'col-1',
      title: 'Rincones de café',
      places: [place],
      recipientIds: ['guest'],
      includeNotes: true,
    );
    final phrase = await owner.enableRecovery();

    expect((await owner.downloadDiary()).single.note, secretNote);
    expect(
      (await guest.openCollection('col-1')).places.single.note,
      secretNote,
    );
    await expectLater(
      intruder.openCollection('col-1'),
      throwsA(isA<E2eeAccessDenied>()),
    );
    final newPhone = await E2eeDevice.restore(
      accountId: 'me',
      phrase: phrase,
      server: backend,
      cipher: cipher,
    );
    expect((await newPhone.downloadDiary()).single.note, secretNote);

    final onDisk = await dataFile.readAsString();
    expect(onDisk, contains('cipherText'));
    for (final secret in [secretNote, place.name, 'Rincones de café', phrase]) {
      expect(onDisk, isNot(contains(secret)), reason: secret);
    }
  });

  test('the inbox lists what others shared, never the owner\'s own, and '
      'revoking removes it', () async {
    final owner = E2eeDevice(accountId: 'me', server: backend, cipher: cipher);
    final guest = E2eeDevice(
      accountId: 'guest',
      server: backend,
      cipher: cipher,
    );
    final intruder = E2eeDevice(
      accountId: 'intruder',
      server: backend,
      cipher: cipher,
    );
    await Future.wait([owner.ready, guest.ready, intruder.ready]);
    await owner.shareCollection(
      collectionId: 'col-1',
      title: 'Rincones de café',
      places: [place],
      recipientIds: ['guest'],
      includeNotes: false,
    );

    final inbox = await backend.inboxOf('guest');
    expect(inbox.single.collectionId, 'col-1');
    expect(inbox.single.ownerId, 'me');
    expect(inbox.single.keyId, isNotEmpty);
    expect(await backend.inboxOf('me'), isEmpty);
    expect(await backend.inboxOf('intruder'), isEmpty);
    expect(await backend.inboxOf('nobody'), isEmpty);
    final raw = await http.get(
      Uri.parse('http://localhost:${server.port}/inbox/guest'),
    );
    expect(raw.headers['access-control-allow-origin'], '*');
    expect(raw.headers['content-type'], contains('application/json'));

    await owner.revokeAccess('col-1', 'guest');

    expect(await backend.inboxOf('guest'), isEmpty);
  });

  test('the admin search finds no clear text', () async {
    final owner = E2eeDevice(accountId: 'me', server: backend, cipher: cipher);
    await owner.uploadPlace(place);

    final response = await http.get(
      Uri.parse(
        'http://localhost:${server.port}/admin/search?q=${Uri.encodeQueryComponent(place.name)}',
      ),
    );

    expect(response.body, contains('"matches":0'));
  });

  test('the flow page and the admin panel link to each other', () async {
    final base = 'http://localhost:${server.port}';
    final flow = await http.get(Uri.parse('$base/admin/flujo'));
    final admin = await http.get(Uri.parse('$base/admin'));

    expect(flow.statusCode, 200);
    expect(flow.headers['content-type'], contains('text/html'));
    expect(flow.body, contains('Flujo del proceso'));
    expect(flow.body, contains('href="/admin"'));
    expect(admin.body, contains('href="/admin/flujo"'));
  });

  test('a stopped server surfaces as BackendUnavailable', () async {
    await server.close(force: true);
    final owner = E2eeDevice(accountId: 'me', server: backend, cipher: cipher);

    await expectLater(
      owner.uploadPlace(place),
      throwsA(isA<BackendUnavailable>()),
    );
  });
}
