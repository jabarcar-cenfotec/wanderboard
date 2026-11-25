import 'package:flutter/widgets.dart';

import '../features/auth/data/fake_auth_service.dart';
import '../features/boards/domain/board.dart';
import '../features/places/domain/place_repository.dart';
import '../features/privacy/application/e2ee_environment.dart';
import '../features/privacy/application/sofia_phone.dart';
import '../features/profile/domain/user_profile.dart';

/// Composition root handed down the tree. Containers read from here;
/// presentational widgets receive plain data.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.boards,
    required this.places,
    required this.auth,
    required this.profile,
    required this.e2ee,
    this.sofia,
    required super.child,
  });

  final BoardRepository boards;
  final PlaceRepository places;
  final FakeAuthService auth;
  final UserProfile profile;

  /// End-to-end encryption proof of concept (research project).
  final E2eeEnvironment e2ee;

  /// Recipient phone of the two-phone demo; only with `rol=sofia`.
  final SofiaPhone? sofia;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      boards != oldWidget.boards ||
      places != oldWidget.places ||
      auth != oldWidget.auth ||
      profile != oldWidget.profile ||
      e2ee != oldWidget.e2ee ||
      sofia != oldWidget.sofia;
}
