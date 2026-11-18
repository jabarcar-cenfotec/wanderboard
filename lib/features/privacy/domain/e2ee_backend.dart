import 'encrypted_models.dart';

/// Port to the backend. It only accepts and returns encrypted models,
/// so no implementation can receive clear text or private keys.
abstract interface class E2eeBackend {
  Future<void> putPublicKey(String accountId, List<int> publicKey);

  Future<List<int>?> publicKeyOf(String accountId);

  Future<void> putRecord(EncryptedRecord record);

  Future<List<EncryptedRecord>> recordsOf(String ownerId);

  Future<void> putCollection(SharedCollection collection);

  Future<SharedCollection?> collection(String id);

  /// Only returns the envelope when [accountId] was granted access.
  Future<WrappedKey?> wrappedKeyFor(String collectionId, String accountId);

  Future<void> putRecoveryBackup(String accountId, RecoveryBackup backup);

  Future<RecoveryBackup?> recoveryBackupOf(String accountId);
}
