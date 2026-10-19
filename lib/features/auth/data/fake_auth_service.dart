import 'package:flutter/foundation.dart';

/// Fake session: sign-in always succeeds instantly (mockup only).
class FakeAuthService extends ChangeNotifier {
  bool _signedIn = false;

  bool get isSignedIn => _signedIn;

  void signIn() {
    _signedIn = true;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    notifyListeners();
  }
}
