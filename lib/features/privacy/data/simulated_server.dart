import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/encrypted_models.dart';

/// In-memory stand-in for the backend. Its API only accepts
/// encrypted models, so it never receives clear text or private keys.
/// [snapshot] is everything it holds, shown in the "server view".
class SimulatedServer extends ChangeNotifier {
  final Map<String, List<int>> _publicKeys = {};
  final Map<String, Map<String, EncryptedRecord>> _records = {};
  final Map<String, SharedCollection> _collections = {};
  final Map<String, RecoveryBackup> _backups = {};

  void registerPublicKey(String accountId, List<int> publicKey) {
    _publicKeys[accountId] = List.unmodifiable(publicKey);
    notifyListeners();
  }

  List<int>? publicKeyOf(String accountId) => _publicKeys[accountId];

  void putRecord(EncryptedRecord record) {
    (_records[record.ownerId] ??= {})[record.id] = record;
    notifyListeners();
  }

  List<EncryptedRecord> recordsOf(String ownerId) =>
      List.unmodifiable(_records[ownerId]?.values ?? const []);

  void putCollection(SharedCollection collection) {
    _collections[collection.id] = collection;
    notifyListeners();
  }

  SharedCollection? collection(String id) => _collections[id];

  /// Authorization check: only grantees receive their key envelope.
  WrappedKey? wrappedKeyFor(String collectionId, String accountId) =>
      _collections[collectionId]?.grants[accountId];

  void putRecoveryBackup(String accountId, RecoveryBackup backup) {
    _backups[accountId] = backup;
    notifyListeners();
  }

  RecoveryBackup? recoveryBackupOf(String accountId) => _backups[accountId];

  int get recordCount =>
      _records.values.fold(0, (total, records) => total + records.length);

  /// Every stored item, exactly as the server sees it.
  List<Map<String, Object?>> snapshot() => [
    for (final entry in _publicKeys.entries)
      {
        'type': 'publicKey',
        'accountId': entry.key,
        'x25519': base64Encode(entry.value),
      },
    for (final records in _records.values)
      for (final record in records.values)
        {'type': 'record', ...record.toJson()},
    for (final collection in _collections.values)
      {'type': 'collection', ...collection.toJson()},
    for (final entry in _backups.entries)
      {
        'type': 'recoveryBackup',
        'accountId': entry.key,
        ...entry.value.toJson(),
      },
  ];

  /// Flips one ciphertext byte of the record at [index] (test T-04).
  @visibleForTesting
  void tamperWithRecord(String ownerId, int index) {
    final records = _records[ownerId]!;
    final record = records.values.elementAt(index);
    final bytes = List.of(record.payload.cipherText);
    bytes[0] ^= 0x01;
    records[record.id] = record.withPayload(
      record.payload.withCipherText(bytes),
    );
  }

  /// Swaps the payloads of two records, keeping their ids.
  @visibleForTesting
  void swapRecordPayloads(String ownerId, int first, int second) {
    final records = _records[ownerId]!;
    final a = records.values.elementAt(first);
    final b = records.values.elementAt(second);
    records[a.id] = a.withPayload(b.payload);
    records[b.id] = b.withPayload(a.payload);
  }
}
