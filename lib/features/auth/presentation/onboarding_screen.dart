import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import 'onboarding_view.dart';

/// Container: asks for the name and wires the fake sign-in to navigation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final photoSeeds = scope.places
        .all()
        .where((place) => place.photos.isNotEmpty)
        .take(3)
        .map((place) => place.cover.seed)
        .toList();
    final canEnter = _name.text.trim().isNotEmpty;

    void enter() {
      scope.auth.signIn(name: _name.text);
      context.go(Routes.home);
    }

    return OnboardingView(
      photoSeeds: photoSeeds,
      nameController: _name,
      onNameChanged: (_) => setState(() {}),
      onStart: canEnter ? enter : null,
      onSignIn: canEnter ? enter : null,
    );
  }
}
