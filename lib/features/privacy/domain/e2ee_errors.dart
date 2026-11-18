/// Ciphertext could not be authenticated: wrong key or modified bytes.
class E2eeIntegrityError implements Exception {
  const E2eeIntegrityError(this.message);

  final String message;

  @override
  String toString() => 'E2eeIntegrityError: $message';
}

/// The server holds no key envelope for this account.
class E2eeAccessDenied implements Exception {
  const E2eeAccessDenied(this.message);

  final String message;

  @override
  String toString() => 'E2eeAccessDenied: $message';
}

/// The recovery phrase is wrong or no backup exists.
class E2eeRecoveryFailed implements Exception {
  const E2eeRecoveryFailed(this.message);

  final String message;

  @override
  String toString() => 'E2eeRecoveryFailed: $message';
}
