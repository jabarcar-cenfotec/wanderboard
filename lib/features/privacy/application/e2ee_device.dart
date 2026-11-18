import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import '../data/e2ee_cipher.dart';
import '../data/place_codec.dart';
import '../domain/e2ee_backend.dart';
import '../domain/e2ee_errors.dart';
import '../domain/encrypted_models.dart';

/// The client side of one account on one device. Keys are created and
/// kept here; the server only receives encrypted models.
///
/// Prototype limitation: keys live in memory. A production client would
/// keep them in Keychain / Android Keystore (research doc, section 3.3).
class E2eeDevice {
  E2eeDevice({
    required String accountId,
    required E2eeBackend server,
    required E2eeCipher cipher,
  }) : this._(
         accountId,
         server,
         cipher,
         seed: E2eeCipher.randomBytes(32),
         dataKey: cipher.newDataKey(),
         dataKeyId: E2eeCipher.randomId(),
       );

  E2eeDevice._(
    this.accountId,
    this._server,
    this._cipher, {
    required this._seed,
    required this._dataKey,
    required this._dataKeyId,
  });

  /// Restores the keys of [accountId] on a new device from its phrase.
  static Future<E2eeDevice> restore({
    required String accountId,
    required String phrase,
    required E2eeBackend server,
    required E2eeCipher cipher,
  }) async {
    final backup = await server.recoveryBackupOf(accountId);
    if (backup == null) {
      throw const E2eeRecoveryFailed('no recovery backup for this account');
    }
    final key = await cipher.recoveryKey(
      RecoveryPhrase.normalize(phrase),
      backup.salt,
      backup.iterations,
    );
    final Map<String, Object?> keys;
    try {
      keys = await cipher.openJson(
        backup.payload,
        key,
        aad: _recoveryAad(accountId),
      ) as Map<String, Object?>;
    } on E2eeIntegrityError {
      throw const E2eeRecoveryFailed('wrong recovery phrase');
    }
    final device = E2eeDevice._(
      accountId,
      server,
      cipher,
      seed: base64Decode(keys['seed']! as String),
      dataKey: SecretKeyData(base64Decode(keys['dataKey']! as String)),
      dataKeyId: keys['dataKeyId']! as String,
    );
    await device.ready;
    return device;
  }

  final String accountId;
  final E2eeBackend _server;
  final E2eeCipher _cipher;
  final List<int> _seed;
  final SecretKey _dataKey;
  final String _dataKeyId;
  late SimpleKeyPair _keyPair;
  Future<void>? _ready;

  /// Completes once the key pair exists and its public half is published.
  /// A failure (e.g. backend offline) is retried on the next call.
  Future<void> get ready => _ready ??= _init().catchError((Object error) {
    _ready = null;
    throw error;
  });

  Future<void> _init() async {
    _keyPair = await _cipher.keyPairFromSeed(_seed);
    final publicKey = await _keyPair.extractPublicKey();
    await _server.putPublicKey(accountId, publicKey.bytes);
  }

  static String _recoveryAad(String accountId) => 'recovery|$accountId';

  String _recordAad(String recordId) => '$accountId|$recordId';

  static String _collectionAad(String id, String keyId) => '$id|$keyId';

  /// Stable opaque id: HMAC of the place id under the data key, so the
  /// server cannot link records to place ids.
  Future<String> _recordId(String placeId) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode('record|$placeId'),
      secretKey: _dataKey,
    );
    return base64Url.encode(mac.bytes).substring(0, 22);
  }

  /// POC-1: encrypts the whole place on the device and uploads it.
  Future<void> uploadPlace(Place place) async {
    await ready;
    final recordId = await _recordId(place.id);
    final payload = await _cipher.sealJson(
      PlaceCodec.toJson(place),
      _dataKey,
      aad: _recordAad(recordId),
    );
    await _server.putRecord(
      EncryptedRecord(
        id: recordId,
        ownerId: accountId,
        keyId: _dataKeyId,
        payload: payload,
      ),
    );
  }

  /// Downloads and decrypts every record of this account.
  Future<List<Place>> downloadDiary() async {
    await ready;
    return [
      for (final record in await _server.recordsOf(accountId))
        PlaceCodec.fromJson(
          await _cipher.openJson(
            record.payload,
            _dataKey,
            aad: _recordAad(record.id),
          ) as Map<String, Object?>,
        ),
    ];
  }

  /// POC-2: encrypts a collection under a fresh key and wraps that key
  /// for the owner and each recipient. Replaces any previous version.
  Future<void> shareCollection({
    required String collectionId,
    required String title,
    required List<Place> places,
    required List<String> recipientIds,
    required bool includeNotes,
  }) => _publish(collectionId, {
    'title': title,
    'places': [
      for (final place in places)
        PlaceCodec.sharedToJson(place, note: includeNotes),
    ],
  }, recipientIds);

  Future<void> _publish(
    String collectionId,
    Map<String, Object?> content,
    List<String> recipientIds,
  ) async {
    await ready;
    final key = _cipher.newDataKey();
    final keyId = E2eeCipher.randomId();
    final sealed = await _cipher.sealJson(
      content,
      key,
      aad: _collectionAad(collectionId, keyId),
    );
    final grants = <String, WrappedKey>{};
    for (final recipientId in {accountId, ...recipientIds}) {
      final publicKey = await _server.publicKeyOf(recipientId);
      if (publicKey == null) {
        throw E2eeAccessDenied('$recipientId has no public key');
      }
      grants[recipientId] = await _cipher.wrapKey(
        key: key,
        keyId: keyId,
        recipientId: recipientId,
        recipientPublicKey: publicKey,
      );
    }
    await _server.putCollection(
      SharedCollection(
        id: collectionId,
        ownerId: accountId,
        keyId: keyId,
        content: sealed,
        grants: grants,
      ),
    );
  }

  /// Opens a collection shared with this account.
  Future<SharedCollectionContent> openCollection(String collectionId) async {
    await ready;
    final wrapped = await _server.wrappedKeyFor(collectionId, accountId);
    if (wrapped == null) {
      throw E2eeAccessDenied('no key for $accountId in $collectionId');
    }
    return openWithWrappedKey(collectionId, wrapped);
  }

  /// Tries to open a collection with a given key envelope, e.g. one
  /// copied from another account (test T-05).
  Future<SharedCollectionContent> openWithWrappedKey(
    String collectionId,
    WrappedKey wrapped,
  ) async {
    final json = await _openRaw(collectionId, wrapped);
    return SharedCollectionContent(
      title: json['title']! as String,
      places: [
        for (final place in json['places']! as List)
          PlaceCodec.sharedFromJson(place as Map<String, Object?>),
      ],
    );
  }

  Future<Map<String, Object?>> _openRaw(
    String collectionId,
    WrappedKey wrapped,
  ) async {
    await ready;
    final collection = await _server.collection(collectionId);
    if (collection == null) {
      throw E2eeAccessDenied('collection $collectionId does not exist');
    }
    final key = await _cipher.unwrapKey(wrapped, _keyPair);
    return await _cipher.openJson(
      collection.content,
      key,
      aad: _collectionAad(collectionId, collection.keyId),
    ) as Map<String, Object?>;
  }

  /// Removes [recipientId] and rotates the key so future versions are
  /// unreadable for them. Copies already decrypted cannot be erased.
  Future<void> revokeAccess(String collectionId, String recipientId) async {
    final own = await _server.wrappedKeyFor(collectionId, accountId);
    if (own == null) {
      throw E2eeAccessDenied('only the owner can revoke access');
    }
    final content = await _openRaw(collectionId, own);
    final remaining = (await _server.collection(collectionId))!.grants.keys
        .where((id) => id != recipientId && id != accountId)
        .toList();
    await _publish(collectionId, content, remaining);
  }

  /// Backs up the device keys encrypted with a new recovery phrase.
  Future<String> enableRecovery() async {
    await ready;
    final phrase = RecoveryPhrase.generate();
    final salt = E2eeCipher.randomBytes(16);
    final iterations = _cipher.recoveryIterations;
    final key = await _cipher.recoveryKey(
      RecoveryPhrase.normalize(phrase),
      salt,
      iterations,
    );
    final payload = await _cipher.sealJson(
      {
        'seed': base64Encode(_seed),
        'dataKey': base64Encode(await _dataKey.extractBytes()),
        'dataKeyId': _dataKeyId,
      },
      key,
      aad: _recoveryAad(accountId),
    );
    await _server.putRecoveryBackup(
      accountId,
      RecoveryBackup(salt: salt, iterations: iterations, payload: payload),
    );
    return phrase;
  }

  @visibleForTesting
  Future<List<int>> debugDataKeyBytes() => _dataKey.extractBytes();
}
