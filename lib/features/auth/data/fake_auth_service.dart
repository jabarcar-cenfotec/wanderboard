import 'package:flutter/foundation.dart';

/// Fake session: sign-in always succeeds instantly (mockup only).
class FakeAuthService extends ChangeNotifier {
  bool _signedIn = false;
  String _name = '';

  bool get isSignedIn => _signedIn;

  /// Name typed on the onboarding screen.
  String get name => _name;

  void signIn({required String name}) {
    _signedIn = true;
    _name = name.trim();
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    notifyListeners();
  }
}
