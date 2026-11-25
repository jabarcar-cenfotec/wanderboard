import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/e2ee_cipher.dart';
import '../domain/e2ee_backend.dart';
import '../domain/e2ee_errors.dart';
import '../domain/encrypted_models.dart';
import 'demo_role.dart';
import 'e2ee_device.dart';

/// One shared collection as the recipient phone knows it.
class IncomingShare {
  IncomingShare(this.collectionId);

  final String collectionId;

  /// Decrypted content, once the recipient opened it.
  SharedCollectionContent? content;

  /// The server no longer grants this account access.
  bool lostAccess = false;
}

/// The recipient phone of the demo: a device with the fixed account
/// [DemoRole.remoteGuestId] that polls its inbox and opens what arrives.
class SofiaPhone extends ChangeNotifier {
  SofiaPhone({
    required E2eeBackend backend,
    required E2eeCipher cipher,
    this.pollInterval = const Duration(seconds: 2),
  }) : _backend = backend,
       device = E2eeDevice(
         accountId: DemoRole.remoteGuestId,
         server: backend,
         cipher: cipher,
       );

  final E2eeBackend _backend;
  final E2eeDevice device;
  final Duration pollInterval;

  final Map<String, IncomingShare> _shares = {};
  Timer? _timer;
  bool _polling = false;
  bool _disposed = false;

  /// Last failure talking to the backend, if any.
  String? error;

  List<IncomingShare> get shares => _shares.values.toList();

  /// Publishes the public key and starts polling the inbox.
  void start() {
    _timer ??= Timer.periodic(pollInterval, (_) => poll());
    poll();
  }

  Future<void> poll() async {
    if (_polling) return;
    _polling = true;
    try {
      await device.ready;
      final inbox = await _backend.inboxOf(device.accountId);
      final current = {for (final entry in inbox) entry.collectionId};
      for (final id in current) {
        final share = _shares[id];
        if (share == null) {
          _shares[id] = IncomingShare(id);
        } else if (share.lostAccess) {
          // Shared again after a revocation: needs opening again.
          share.lostAccess = false;
          share.content = null;
        }
      }
      for (final share in _shares.values) {
        if (!current.contains(share.collectionId)) {
          share.lostAccess = true;
          share.content = null;
        }
      }
      error = null;
    } on Exception catch (e) {
      error = '$e';
    } finally {
      _polling = false;
      _notify();
    }
  }

  /// Decrypts the collection; a missing or unusable key means no access.
  Future<void> open(String collectionId) async {
    final share = _shares[collectionId];
    if (share == null) return;
    try {
      share.content = await device.openCollection(collectionId);
      share.lostAccess = false;
    } on E2eeAccessDenied {
      share.lostAccess = true;
    } on E2eeIntegrityError {
      share.lostAccess = true;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
