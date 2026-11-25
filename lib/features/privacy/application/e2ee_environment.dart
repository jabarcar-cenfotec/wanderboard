import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import '../../places/domain/place_repository.dart';
import '../data/e2ee_cipher.dart';
import '../domain/e2ee_backend.dart';
import '../domain/encrypted_models.dart';
import 'demo_role.dart';
import 'e2ee_device.dart';

/// Test account that receives a shared collection.
const guestName = 'Sofía';

/// Everything the E2EE proof of concept needs: the backend, the user's
/// device, two test accounts standing in for other phones, and automatic
/// encrypted sync of the diary.
class E2eeEnvironment extends ChangeNotifier {
  E2eeEnvironment({
    required this._places,
    required this.backend,
    this.adminUrl,
    E2eeCipher? cipher,
    String? sessionTag,
    this.role = DemoRole.standalone,
  }) : cipher = cipher ?? E2eeCipher(),
       sessionTag = sessionTag ?? E2eeCipher.randomId().substring(0, 4) {
    // Keys live in memory, so each app launch is a new set of accounts;
    // the tag keeps them apart in the persistent backend.
    me = _device('mi-cuenta');
    guest = _device('sofia');
    intruder = _device('cuenta-no-autorizada');
    // The recipient phone has no diary of its own to sync.
    if (role != DemoRole.recipient) {
      _places.addListener(_scheduleSync);
      _scheduleSync();
    }
  }

  final PlaceRepository _places;
  final E2eeBackend backend;
  final E2eeCipher cipher;

  /// Admin panel of the backend, when it has one.
  final Uri? adminUrl;
  final String sessionTag;

  /// Which phone of the two-phone demo this instance is.
  final DemoRole role;

  /// Whether the guest is another app instance instead of the internal
  /// test account.
  bool get hasRemoteGuest => role == DemoRole.sender;

  /// Account that shares go to and that access is revoked from.
  String get guestAccountId =>
      hasRemoteGuest ? DemoRole.remoteGuestId : guest.accountId;

  late final E2eeDevice me;
  late final E2eeDevice guest;
  late final E2eeDevice intruder;

  E2eeDevice _device(String name) => E2eeDevice(
    accountId: '$name-$sessionTag',
    server: backend,
    cipher: cipher,
  );

  final Map<String, Place> _synced = {};
  Future<void> _queue = Future.value();

  /// Collection currently shared with the guest, if any.
  String? sharedCollectionId;
  String? sharedTitle;
  bool guestHasAccess = false;

  /// Phrase shown once after enabling recovery.
  String? recoveryPhrase;

  /// Last sync failure, e.g. the backend is not running.
  String? syncError;

  /// Places encrypted and uploaded so far.
  int get syncedCount => _synced.length;

  /// Completes when every pending change has been uploaded.
  Future<void> get idle => _queue;

  void _scheduleSync() {
    _queue = _queue.then((_) => _syncChanged());
  }

  /// Retries uploading whatever is still pending.
  void retrySync() => _scheduleSync();

  Future<void> _syncChanged() async {
    try {
      await Future.wait([me.ready, guest.ready, intruder.ready]);
      for (final place in _places.all()) {
        if (identical(_synced[place.id], place)) continue;
        await me.uploadPlace(place);
        _synced[place.id] = place;
        syncError = null;
        notifyListeners();
      }
    } on Exception catch (error) {
      syncError = '$error';
      notifyListeners();
    }
  }

  /// Returns false, sharing nothing, when the remote guest phone has not
  /// published its key yet.
  Future<bool> shareWithGuest({
    required String collectionTitle,
    required List<Place> places,
    required bool includeNotes,
  }) async {
    if (hasRemoteGuest &&
        await backend.publicKeyOf(DemoRole.remoteGuestId) == null) {
      return false;
    }
    final id = sharedCollectionId ?? E2eeCipher.randomId();
    await me.shareCollection(
      collectionId: id,
      title: collectionTitle,
      places: places,
      recipientIds: [guestAccountId],
      includeNotes: includeNotes,
    );
    sharedCollectionId = id;
    sharedTitle = collectionTitle;
    guestHasAccess = true;
    notifyListeners();
    return true;
  }

  Future<void> revokeGuest() async {
    final id = sharedCollectionId;
    if (id == null) return;
    await me.revokeAccess(id, guestAccountId);
    guestHasAccess = false;
    notifyListeners();
  }

  Future<SharedCollectionContent> openAs(E2eeDevice device) =>
      device.openCollection(sharedCollectionId!);

  Future<String> enableRecovery() async {
    await idle;
    recoveryPhrase = await me.enableRecovery();
    notifyListeners();
    return recoveryPhrase!;
  }

  /// Simulates a new phone: restores keys from [phrase] and decrypts.
  Future<List<Place>> restoreOnNewDevice(String phrase) async {
    final device = await E2eeDevice.restore(
      accountId: me.accountId,
      phrase: phrase,
      server: backend,
      cipher: cipher,
    );
    return device.downloadDiary();
  }

  @override
  void dispose() {
    _places.removeListener(_scheduleSync);
    super.dispose();
  }
}
