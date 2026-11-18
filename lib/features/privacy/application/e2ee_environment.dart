import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import '../../places/domain/place_repository.dart';
import '../data/e2ee_cipher.dart';
import '../data/simulated_server.dart';
import '../domain/encrypted_models.dart';
import 'e2ee_device.dart';

/// Test account that receives a shared collection.
const guestName = 'Sofía';

/// Everything the E2EE proof of concept needs: the simulated server,
/// the user's device, two test accounts on other devices, and automatic
/// encrypted sync of the diary.
class E2eeEnvironment extends ChangeNotifier {
  E2eeEnvironment({required this._places, E2eeCipher? cipher})
    : cipher = cipher ?? E2eeCipher() {
    me = E2eeDevice(
      accountId: 'mi-cuenta',
      server: server,
      cipher: this.cipher,
    );
    guest = E2eeDevice(accountId: 'sofia', server: server, cipher: this.cipher);
    intruder = E2eeDevice(
      accountId: 'cuenta-no-autorizada',
      server: server,
      cipher: this.cipher,
    );
    _places.addListener(_scheduleSync);
    _scheduleSync();
  }

  final PlaceRepository _places;
  final E2eeCipher cipher;
  final SimulatedServer server = SimulatedServer();
  late final E2eeDevice me;
  late final E2eeDevice guest;
  late final E2eeDevice intruder;

  final Map<String, Place> _synced = {};
  Future<void> _queue = Future.value();

  /// Collection currently shared with the guest, if any.
  String? sharedCollectionId;
  String? sharedTitle;
  bool guestHasAccess = false;

  /// Phrase shown once after enabling recovery.
  String? recoveryPhrase;

  /// Places encrypted and uploaded so far.
  int get syncedCount => _synced.length;

  /// Completes when every pending change has been uploaded.
  Future<void> get idle => _queue;

  void _scheduleSync() {
    _queue = _queue.then((_) => _syncChanged());
  }

  Future<void> _syncChanged() async {
    var changed = false;
    for (final place in _places.all()) {
      if (identical(_synced[place.id], place)) continue;
      await me.uploadPlace(place);
      _synced[place.id] = place;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> shareWithGuest({
    required String collectionTitle,
    required List<Place> places,
    required bool includeNotes,
  }) async {
    final id = sharedCollectionId ?? E2eeCipher.randomId();
    await me.shareCollection(
      collectionId: id,
      title: collectionTitle,
      places: places,
      recipientIds: [guest.accountId],
      includeNotes: includeNotes,
    );
    sharedCollectionId = id;
    sharedTitle = collectionTitle;
    guestHasAccess = true;
    notifyListeners();
  }

  Future<void> revokeGuest() async {
    final id = sharedCollectionId;
    if (id == null) return;
    await me.revokeAccess(id, guest.accountId);
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
      server: server,
      cipher: cipher,
    );
    return device.downloadDiary();
  }

  @override
  void dispose() {
    _places.removeListener(_scheduleSync);
    server.dispose();
    super.dispose();
  }
}
