import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Version of the encryption scheme, stored with every payload so the
/// format can migrate later (research doc, section 3.4).
const cryptoVersion = 'v1-aes256gcm';

/// Output of authenticated encryption: nonce, ciphertext and tag.
@immutable
class SealedPayload {
  const SealedPayload({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final List<int> nonce;
  final List<int> cipherText;
  final List<int> mac;

  factory SealedPayload.fromJson(Map<String, Object?> json) => SealedPayload(
    nonce: base64Decode(json['nonce']! as String),
    cipherText: base64Decode(json['cipherText']! as String),
    mac: base64Decode(json['mac']! as String),
  );

  Map<String, Object?> toJson() => {
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  SealedPayload withCipherText(List<int> bytes) =>
      SealedPayload(nonce: nonce, cipherText: bytes, mac: mac);
}

/// One private diary entry as the server stores it.
@immutable
class EncryptedRecord {
  const EncryptedRecord({
    required this.id,
    required this.ownerId,
    required this.keyId,
    required this.payload,
    this.version = cryptoVersion,
  });

  /// Opaque id; it is not the place id.
  final String id;
  final String ownerId;
  final String keyId;
  final String version;
  final SealedPayload payload;

  factory EncryptedRecord.fromJson(Map<String, Object?> json) =>
      EncryptedRecord(
        id: json['id']! as String,
        ownerId: json['ownerId']! as String,
        keyId: json['keyId']! as String,
        version: json['cryptoVersion']! as String,
        payload: SealedPayload.fromJson(json),
      );

  EncryptedRecord withPayload(SealedPayload next) => EncryptedRecord(
    id: id,
    ownerId: ownerId,
    keyId: keyId,
    payload: next,
    version: version,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'keyId': keyId,
    'cryptoVersion': version,
    ...payload.toJson(),
  };
}

/// A collection key encrypted for one recipient (ephemeral X25519 + HKDF).
@immutable
class WrappedKey {
  const WrappedKey({
    required this.keyId,
    required this.recipientId,
    required this.ephemeralPublicKey,
    required this.payload,
  });

  factory WrappedKey.fromJson(Map<String, Object?> json) => WrappedKey(
    keyId: json['keyId']! as String,
    recipientId: json['recipientId']! as String,
    ephemeralPublicKey: base64Decode(json['ephemeralPublicKey']! as String),
    payload: SealedPayload.fromJson(json),
  );

  final String keyId;
  final String recipientId;
  final List<int> ephemeralPublicKey;
  final SealedPayload payload;

  Map<String, Object?> toJson() => {
    'keyId': keyId,
    'recipientId': recipientId,
    'ephemeralPublicKey': base64Encode(ephemeralPublicKey),
    ...payload.toJson(),
  };
}

/// A shared collection: one encrypted content blob plus one key envelope
/// per authorized account.
@immutable
class SharedCollection {
  const SharedCollection({
    required this.id,
    required this.ownerId,
    required this.keyId,
    required this.content,
    required this.grants,
  });

  factory SharedCollection.fromJson(Map<String, Object?> json) {
    final grants = [
      for (final grant in json['grants']! as List)
        WrappedKey.fromJson((grant as Map).cast<String, Object?>()),
    ];
    return SharedCollection(
      id: json['id']! as String,
      ownerId: json['ownerId']! as String,
      keyId: json['keyId']! as String,
      content: SealedPayload.fromJson(
        (json['content']! as Map).cast<String, Object?>(),
      ),
      grants: {for (final grant in grants) grant.recipientId: grant},
    );
  }

  final String id;
  final String ownerId;
  final String keyId;
  final SealedPayload content;

  /// Recipient id → wrapped collection key.
  final Map<String, WrappedKey> grants;

  Map<String, Object?> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'keyId': keyId,
    'cryptoVersion': cryptoVersion,
    'content': content.toJson(),
    'grants': [for (final grant in grants.values) grant.toJson()],
  };
}

/// The device keys encrypted with a key derived from the recovery phrase.
@immutable
class RecoveryBackup {
  const RecoveryBackup({
    required this.salt,
    required this.iterations,
    required this.payload,
  });

  factory RecoveryBackup.fromJson(Map<String, Object?> json) => RecoveryBackup(
    salt: base64Decode(json['salt']! as String),
    iterations: json['iterations']! as int,
    payload: SealedPayload.fromJson(json),
  );

  final List<int> salt;
  final int iterations;
  final SealedPayload payload;

  Map<String, Object?> toJson() => {
    'kdf': 'PBKDF2-HMAC-SHA256',
    'salt': base64Encode(salt),
    'iterations': iterations,
    ...payload.toJson(),
  };
}

/// What a recipient sees after decrypting a shared collection.
@immutable
class SharedCollectionContent {
  const SharedCollectionContent({required this.title, required this.places});

  final String title;
  final List<SharedPlace> places;
}

/// The subset of a place that travels inside a shared collection.
@immutable
class SharedPlace {
  const SharedPlace({
    required this.name,
    required this.location,
    required this.rating,
    required this.note,
  });

  final String name;
  final String location;
  final int rating;

  /// Empty unless the owner chose to include private notes.
  final String note;
}
