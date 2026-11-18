import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/data/seed_places.dart';
import 'package:wanderboard/features/places/domain/place.dart';
import 'package:wanderboard/features/privacy/application/e2ee_device.dart';
import 'package:wanderboard/features/privacy/data/e2ee_cipher.dart';
import 'package:wanderboard/features/privacy/data/simulated_server.dart';
import 'package:wanderboard/features/privacy/domain/e2ee_errors.dart';

/// Technical tests T-01..T-08 from the research document (section 3.6).
void main() {
  // Low PBKDF2 cost keeps the suite fast; the app uses the production value.
  final cipher = E2eeCipher(recoveryIterations: 1000);
  late SimulatedServer server;
  late E2eeDevice owner;

  const secretNote = 'Pedir el queque de zanahoria, mesa junto a la ventana';
  final place = seedPlaces.first.copyWith(note: secretNote);

  setUp(() async {
    server = SimulatedServer();
    owner = E2eeDevice(accountId: 'owner', server: server, cipher: cipher);
    await owner.ready;
  });

  String serverDump() => jsonEncode(server.snapshot());

  test('T-01 the server only stores ciphertext, nonce and metadata', () async {
    await owner.uploadPlace(place);

    final stored = server.recordsOf('owner').single.toJson();
    expect(
      stored.keys,
      containsAll(['id', 'keyId', 'cryptoVersion', 'nonce', 'cipherText']),
    );
    expect(serverDump(), isNot(contains(secretNote)));
    expect(serverDump(), isNot(contains(place.name)));
  });

  test('T-02 the authorized device recovers the exact original note', () async {
    await owner.uploadPlace(place);

    final restored = await owner.downloadDiary();

    expect(restored.single.note, secretNote);
    expect(restored.single.name, place.name);
    expect(restored.single.rating, place.rating);
  });

  test('T-03 a wrong key fails without returning readable text', () async {
    await owner.uploadPlace(place);
    final other = E2eeDevice(
      accountId: 'owner',
      server: server,
      cipher: cipher,
    );
    await other.ready;

    expect(other.downloadDiary(), throwsA(isA<E2eeIntegrityError>()));
  });

  test(
    'T-04 changing one byte of the ciphertext fails authentication',
    () async {
      await owner.uploadPlace(place);
      server.tamperWithRecord('owner', 0);

      expect(owner.downloadDiary(), throwsA(isA<E2eeIntegrityError>()));
    },
  );

  group('shared collections', () {
    late E2eeDevice guest;
    late E2eeDevice intruder;
    const collectionId = 'col-test';

    setUp(() async {
      guest = E2eeDevice(accountId: 'guest', server: server, cipher: cipher);
      intruder = E2eeDevice(
        accountId: 'intruder',
        server: server,
        cipher: cipher,
      );
      await Future.wait([guest.ready, intruder.ready]);
      await owner.shareCollection(
        collectionId: collectionId,
        title: 'Rincones de café',
        places: [place],
        recipientIds: ['guest'],
        includeNotes: false,
      );
    });

    test('T-05 an unauthorized account gets no valid key', () async {
      expect(
        intruder.openCollection(collectionId),
        throwsA(isA<E2eeAccessDenied>()),
      );
    });

    test('T-05 a stolen wrapped key is useless without the private key', () {
      final stolen = server.wrappedKeyFor(collectionId, 'guest')!;
      expect(
        intruder.openWithWrappedKey(collectionId, stolen),
        throwsA(isA<E2eeIntegrityError>()),
      );
    });

    test('T-06 the recipient decrypts; private notes stay out', () async {
      final shared = await guest.openCollection(collectionId);

      expect(shared.title, 'Rincones de café');
      expect(shared.places.single.name, place.name);
      expect(shared.places.single.note, isEmpty);
      expect(serverDump(), isNot(contains('Rincones de café')));
    });

    test('T-06 notes travel only when the owner opts in', () async {
      await owner.shareCollection(
        collectionId: collectionId,
        title: 'Rincones de café',
        places: [place],
        recipientIds: ['guest'],
        includeNotes: true,
      );

      final shared = await guest.openCollection(collectionId);

      expect(shared.places.single.note, secretNote);
    });

    test('revoking rotates the key and blocks future access', () async {
      final keyBefore = server.collection(collectionId)!.keyId;

      await owner.revokeAccess(collectionId, 'guest');

      expect(server.collection(collectionId)!.keyId, isNot(keyBefore));
      expect(
        guest.openCollection(collectionId),
        throwsA(isA<E2eeAccessDenied>()),
      );
      final ownView = await owner.openCollection(collectionId);
      expect(ownView.places.single.name, place.name);
    });
  });

  group('T-07 recovery on a new device', () {
    test('restores the diary only with the right phrase', () async {
      await owner.uploadPlace(place);
      final phrase = await owner.enableRecovery();

      final newPhone = await E2eeDevice.restore(
        accountId: 'owner',
        phrase: phrase,
        server: server,
        cipher: cipher,
      );

      expect((await newPhone.downloadDiary()).single.note, secretNote);
    });

    test('accepts the phrase in lower case and without dashes', () async {
      await owner.uploadPlace(place);
      final phrase = await owner.enableRecovery();

      final newPhone = await E2eeDevice.restore(
        accountId: 'owner',
        phrase: phrase.toLowerCase().replaceAll('-', ' '),
        server: server,
        cipher: cipher,
      );

      expect((await newPhone.downloadDiary()).single.note, secretNote);
    });

    test('rejects a wrong phrase', () async {
      await owner.uploadPlace(place);
      await owner.enableRecovery();

      expect(
        E2eeDevice.restore(
          accountId: 'owner',
          phrase: 'AAAA-BBBB-CCCC-DDDD-EEEE-FFFF',
          server: server,
          cipher: cipher,
        ),
        throwsA(isA<E2eeRecoveryFailed>()),
      );
    });

    test('fails clearly when recovery was never enabled', () {
      expect(
        E2eeDevice.restore(
          accountId: 'owner',
          phrase: 'AAAA-BBBB-CCCC-DDDD-EEEE-FFFF',
          server: server,
          cipher: cipher,
        ),
        throwsA(isA<E2eeRecoveryFailed>()),
      );
    });
  });

  test('T-08 no notes or keys in clear anywhere on the server', () async {
    await owner.uploadPlace(place);
    final phrase = await owner.enableRecovery();
    final guest = E2eeDevice(
      accountId: 'guest',
      server: server,
      cipher: cipher,
    );
    await guest.ready;
    await owner.shareCollection(
      collectionId: 'col-1',
      title: 'Kioto bajo la lluvia',
      places: [place],
      recipientIds: ['guest'],
      includeNotes: true,
    );

    final dump = serverDump();
    for (final secret in [
      secretNote,
      place.name,
      'Kioto bajo la lluvia',
      phrase,
      base64Encode(await owner.debugDataKeyBytes()),
    ]) {
      expect(dump, isNot(contains(secret)), reason: secret);
    }
  });

  test('a record cannot be swapped onto another place id', () async {
    final second = seedPlaces[1];
    await owner.uploadPlace(place);
    await owner.uploadPlace(second);
    server.swapRecordPayloads('owner', 0, 1);

    expect(owner.downloadDiary(), throwsA(isA<E2eeIntegrityError>()));
  });

  test('every place field survives the round trip', () async {
    final full = Place(
      id: 'p-full',
      name: 'Mirador',
      city: 'Cartago',
      country: 'Costa Rica',
      boardIds: const ['a', 'b'],
      rating: 4,
      note: 'nota',
      photos: const [PlacePhoto('seed-1', aspectRatio: 1.25)],
      visitedOn: DateTime(2026, 3, 14),
      status: PlaceStatus.wantToReturn,
      tags: const ['vista'],
      type: PlaceType.viewpoint,
      address: 'Ruta 2',
      isSample: true,
    );
    await owner.uploadPlace(full);

    final back = (await owner.downloadDiary()).single;

    expect(back.boardIds, full.boardIds);
    expect(back.photos.single.seed, 'seed-1');
    expect(back.photos.single.aspectRatio, 1.25);
    expect(back.visitedOn, full.visitedOn);
    expect(back.status, full.status);
    expect(back.tags, full.tags);
    expect(back.type, full.type);
    expect(back.address, full.address);
    expect(back.isSample, isTrue);
  });
}
