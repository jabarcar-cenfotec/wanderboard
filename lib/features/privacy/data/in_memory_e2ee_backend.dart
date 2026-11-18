import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/e2ee_backend.dart';
import '../domain/encrypted_models.dart';

/// In-process backend used by tests. The demo uses [HttpE2eeBackend]
/// against the separate local server in `backend/`.
class InMemoryE2eeBackend implements E2eeBackend {
  final Map<String, List<int>> _publicKeys = {};
  final Map<String, Map<String, EncryptedRecord>> _records = {};
  final Map<String, SharedCollection> _collections = {};
  final Map<String, RecoveryBackup> _backups = {};

  @override
  Future<void> putPublicKey(String accountId, List<int> publicKey) async =>
      _publicKeys[accountId] = List.unmodifiable(publicKey);

  @override
  Future<List<int>?> publicKeyOf(String accountId) async =>
      _publicKeys[accountId];

  @override
  Future<void> putRecord(EncryptedRecord record) async =>
      (_records[record.ownerId] ??= {})[record.id] = record;

  @override
  Future<List<EncryptedRecord>> recordsOf(String ownerId) async =>
      List.unmodifiable(_records[ownerId]?.values ?? const []);

  @override
  Future<void> putCollection(SharedCollection collection) async =>
      _collections[collection.id] = collection;

  @override
  Future<SharedCollection?> collection(String id) async => _collections[id];

  @override
  Future<WrappedKey?> wrappedKeyFor(
    String collectionId,
    String accountId,
  ) async => _collections[collectionId]?.grants[accountId];

  @override
  Future<void> putRecoveryBackup(
    String accountId,
    RecoveryBackup backup,
  ) async => _backups[accountId] = backup;

  @override
  Future<RecoveryBackup?> recoveryBackupOf(String accountId) async =>
      _backups[accountId];

  /// Everything stored, as JSON text (used to look for leaked secrets).
  String dump() => jsonEncode({
    'publicKeys': {
      for (final entry in _publicKeys.entries)
        entry.key: base64Encode(entry.value),
    },
    'records': [
      for (final records in _records.values)
        for (final record in records.values) record.toJson(),
    ],
    'collections': [for (final c in _collections.values) c.toJson()],
    'recoveryBackups': {
      for (final entry in _backups.entries) entry.key: entry.value.toJson(),
    },
  });

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
