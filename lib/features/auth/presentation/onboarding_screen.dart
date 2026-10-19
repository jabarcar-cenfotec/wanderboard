import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import 'onboarding_view.dart';

/// Container: wires the fake sign-in to navigation.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final photoSeeds = scope.places
        .all()
        .take(3)
        .map((place) => place.cover.seed)
        .toList();

    void enter() {
      scope.auth.signIn();
      context.go(Routes.home);
    }

    return OnboardingView(
      photoSeeds: photoSeeds,
      onStart: enter,
      onSignIn: enter,
    );
  }
}
