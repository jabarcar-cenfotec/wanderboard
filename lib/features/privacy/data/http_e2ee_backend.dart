import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/e2ee_backend.dart';
import '../domain/encrypted_models.dart';

/// Thrown when the local backend cannot be reached or answers an error.
class BackendUnavailable implements Exception {
  const BackendUnavailable(this.message);

  final String message;

  @override
  String toString() => 'BackendUnavailable: $message';
}

/// Talks to the local demo server in `backend/` over HTTP.
class HttpE2eeBackend implements E2eeBackend {
  HttpE2eeBackend(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUrl;
  final http.Client _client;

  /// Admin panel of the server, shown in the app for the demo.
  Uri get adminUrl => baseUrl.resolve('admin');

  Uri _url(List<String> segments) => baseUrl.replace(
    pathSegments: [
      ...baseUrl.pathSegments.where((s) => s.isNotEmpty),
      ...segments,
    ],
  );

  Future<void> _put(List<String> segments, Object? body) async {
    final response = await _send(
      () => _client.put(
        _url(segments),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode != 200) {
      throw BackendUnavailable(
        'PUT ${segments.join('/')}: ${response.statusCode}',
      );
    }
  }

  /// Decoded JSON, or null on 404.
  Future<Object?> _get(List<String> segments) async {
    final response = await _send(() => _client.get(_url(segments)));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw BackendUnavailable(
        'GET ${segments.join('/')}: ${response.statusCode}',
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on http.ClientException catch (error) {
      throw BackendUnavailable(error.message);
    }
  }

  static Map<String, Object?> _map(Object? json) =>
      (json! as Map).cast<String, Object?>();

  @override
  Future<void> putPublicKey(String accountId, List<int> publicKey) =>
      _put(['keys', accountId], {'x25519': base64Encode(publicKey)});

  @override
  Future<List<int>?> publicKeyOf(String accountId) async {
    final json = await _get(['keys', accountId]);
    return json == null ? null : base64Decode(_map(json)['x25519']! as String);
  }

  @override
  Future<void> putRecord(EncryptedRecord record) =>
      _put(['records', record.ownerId, record.id], record.toJson());

  @override
  Future<List<EncryptedRecord>> recordsOf(String ownerId) async {
    final json = await _get(['records', ownerId]) as List? ?? const [];
    return [for (final item in json) EncryptedRecord.fromJson(_map(item))];
  }

  @override
  Future<void> putCollection(SharedCollection collection) =>
      _put(['collections', collection.id], collection.toJson());

  @override
  Future<SharedCollection?> collection(String id) async {
    final json = await _get(['collections', id]);
    return json == null ? null : SharedCollection.fromJson(_map(json));
  }

  @override
  Future<WrappedKey?> wrappedKeyFor(
    String collectionId,
    String accountId,
  ) async {
    final json = await _get(['collections', collectionId, 'grants', accountId]);
    return json == null ? null : WrappedKey.fromJson(_map(json));
  }

  @override
  Future<void> putRecoveryBackup(String accountId, RecoveryBackup backup) =>
      _put(['recovery', accountId], backup.toJson());

  @override
  Future<RecoveryBackup?> recoveryBackupOf(String accountId) async {
    final json = await _get(['recovery', accountId]);
    return json == null ? null : RecoveryBackup.fromJson(_map(json));
  }
}
