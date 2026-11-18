import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../domain/e2ee_errors.dart';
import '../domain/encrypted_models.dart';

/// Recommended PBKDF2-HMAC-SHA256 cost (OWASP Password Storage Cheat Sheet).
const defaultRecoveryIterations = 600000;

/// Thin wrapper over the `cryptography` package. No custom algorithms:
/// AES-256-GCM for data, X25519 + HKDF-SHA256 to wrap keys for a
/// recipient, PBKDF2-HMAC-SHA256 for the recovery phrase.
class E2eeCipher {
  E2eeCipher({this.recoveryIterations = defaultRecoveryIterations});

  final int recoveryIterations;

  static final _aes = AesGcm.with256bits();
  static final _x25519 = X25519();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static final _random = Random.secure();
  static final _wrapInfo = utf8.encode('spotly-key-wrap-v1');

  static List<int> randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  /// Random 128-bit id that reveals nothing about the content.
  static String randomId() =>
      base64Url.encode(randomBytes(16)).replaceAll('=', '');

  SecretKey newDataKey() => SecretKeyData(randomBytes(32));

  Future<SimpleKeyPair> keyPairFromSeed(List<int> seed) =>
      _x25519.newKeyPairFromSeed(seed);

  Future<SealedPayload> seal(
    List<int> clearBytes,
    SecretKey key, {
    required List<int> aad,
  }) async {
    final box = await _aes.encrypt(
      clearBytes,
      secretKey: key,
      nonce: _aes.newNonce(),
      aad: aad,
    );
    return SealedPayload(
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac.bytes,
    );
  }

  Future<List<int>> open(
    SealedPayload sealed,
    SecretKey key, {
    required List<int> aad,
  }) async {
    try {
      return await _aes.decrypt(
        SecretBox(sealed.cipherText, nonce: sealed.nonce, mac: Mac(sealed.mac)),
        secretKey: key,
        aad: aad,
      );
    } on SecretBoxAuthenticationError {
      throw const E2eeIntegrityError('authentication failed');
    }
  }

  Future<SealedPayload> sealJson(
    Object? value,
    SecretKey key, {
    required String aad,
  }) => seal(utf8.encode(jsonEncode(value)), key, aad: utf8.encode(aad));

  Future<Object?> openJson(
    SealedPayload sealed,
    SecretKey key, {
    required String aad,
  }) async =>
      jsonDecode(utf8.decode(await open(sealed, key, aad: utf8.encode(aad))));

  /// Encrypts [key] so only the holder of [recipientPublicKey] can read it.
  Future<WrappedKey> wrapKey({
    required SecretKey key,
    required String keyId,
    required String recipientId,
    required List<int> recipientPublicKey,
  }) async {
    final ephemeral = await _x25519.newKeyPair();
    final ephemeralPublic = (await ephemeral.extractPublicKey()).bytes;
    final kek = await _kek(
      ephemeral,
      SimplePublicKey(recipientPublicKey, type: KeyPairType.x25519),
      keyId,
    );
    final payload = await seal(
      await key.extractBytes(),
      kek,
      aad: utf8.encode('$keyId|$recipientId'),
    );
    return WrappedKey(
      keyId: keyId,
      recipientId: recipientId,
      ephemeralPublicKey: ephemeralPublic,
      payload: payload,
    );
  }

  Future<SecretKey> unwrapKey(WrappedKey wrapped, SimpleKeyPair own) async {
    final kek = await _kek(
      own,
      SimplePublicKey(wrapped.ephemeralPublicKey, type: KeyPairType.x25519),
      wrapped.keyId,
    );
    final bytes = await open(
      wrapped.payload,
      kek,
      aad: utf8.encode('${wrapped.keyId}|${wrapped.recipientId}'),
    );
    return SecretKeyData(bytes);
  }

  Future<SecretKey> _kek(
    SimpleKeyPair own,
    SimplePublicKey remote,
    String keyId,
  ) async {
    final shared = await _x25519.sharedSecretKey(
      keyPair: own,
      remotePublicKey: remote,
    );
    return _hkdf.deriveKey(
      secretKey: shared,
      nonce: utf8.encode(keyId),
      info: _wrapInfo,
    );
  }

  Future<SecretKey> recoveryKey(String phrase, List<int> salt, int iterations) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(phrase)),
      nonce: salt,
    );
  }
}

/// Recovery phrase: 6 groups of 4 characters (120 bits of randomness).
abstract final class RecoveryPhrase {
  // Crockford base32: no I, L, O, U to avoid reading mistakes.
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String generate() {
    final random = Random.secure();
    final groups = List.generate(
      6,
      (_) => List.generate(
        4,
        (_) => _alphabet[random.nextInt(_alphabet.length)],
      ).join(),
    );
    return groups.join('-');
  }

  /// Ignores case, spaces and dashes so typing it back is forgiving.
  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');
}
