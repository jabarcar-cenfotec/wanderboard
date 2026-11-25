import 'dart:convert';
import 'dart:io';

/// Everything the backend knows, kept as the JSON clients sent.
///
/// The store never parses or decrypts payloads: it only files them by
/// account or id. When [file] is set, every change is written to disk so
/// the data can also be inspected outside the admin panel.
class E2eeStore {
  E2eeStore({this.file}) {
    final source = file;
    if (source != null && source.existsSync()) {
      final saved = jsonDecode(source.readAsStringSync()) as Map;
      _data.addAll(saved.cast<String, Object?>());
    }
    for (final section in sections) {
      _data.putIfAbsent(section, () => <String, Object?>{});
    }
  }

  static const sections = [
    'publicKeys',
    'records',
    'collections',
    'recoveryBackups',
  ];

  final File? file;
  final Map<String, Object?> _data = {};

  Map<String, Object?> _section(String name) =>
      (_data[name]! as Map).cast<String, Object?>();

  void putPublicKey(String accountId, Object? json) =>
      _write(() => _section('publicKeys')[accountId] = json);

  Object? publicKey(String accountId) => _section('publicKeys')[accountId];

  void putRecord(String ownerId, String recordId, Object? json) => _write(() {
    final owners = _section('records');
    final records = (owners[ownerId] as Map?)?.cast<String, Object?>() ?? {};
    records[recordId] = json;
    owners[ownerId] = records;
  });

  List<Object?> records(String ownerId) =>
      ((_section('records')[ownerId] as Map?)?.values.toList()) ?? const [];

  void putCollection(String id, Object? json) =>
      _write(() => _section('collections')[id] = json);

  Map<String, Object?>? collection(String id) =>
      (_section('collections')[id] as Map?)?.cast<String, Object?>();

  /// The key envelope for [accountId], only if it was granted access.
  Object? grant(String collectionId, String accountId) {
    final grants = collection(collectionId)?['grants'] as List?;
    for (final grant in grants ?? const []) {
      if ((grant as Map)['recipientId'] == accountId) return grant;
    }
    return null;
  }

  /// Collections shared with [accountId] by someone else (the owner's own
  /// grant is not an incoming share).
  List<Map<String, Object?>> inbox(String accountId) {
    final inbox = <Map<String, Object?>>[];
    for (final entry in _section('collections').entries) {
      final collection = (entry.value as Map).cast<String, Object?>();
      final ownerId = collection['ownerId'];
      if (ownerId == accountId) continue;
      final grant = this.grant(entry.key, accountId);
      if (grant == null) continue;
      inbox.add({
        'collectionId': entry.key,
        'ownerId': ownerId,
        'keyId': (grant as Map)['keyId'],
      });
    }
    return inbox;
  }

  void putRecoveryBackup(String accountId, Object? json) =>
      _write(() => _section('recoveryBackups')[accountId] = json);

  Object? recoveryBackup(String accountId) =>
      _section('recoveryBackups')[accountId];

  void reset() => _write(() {
    for (final section in sections) {
      _data[section] = <String, Object?>{};
    }
  });

  Map<String, Object?> snapshot() =>
      jsonDecode(jsonEncode(_data)) as Map<String, Object?>;

  /// Raw stored text, as written to disk.
  String rawText() => const JsonEncoder.withIndent('  ').convert(_data);

  void _write(void Function() change) {
    change();
    file?.writeAsStringSync(rawText());
  }
}
