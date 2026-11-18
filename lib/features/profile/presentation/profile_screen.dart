import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../domain/user_profile.dart';
import 'profile_view.dart';

/// Container for the profile tab.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    void mock(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    return ListenableBuilder(
      listenable: scope.places,
      builder: (context, _) => ProfileView(
        profile: scope.profile.named(scope.auth.name),
        stats: DiaryStats.from(
          places: scope.places.all(),
          boardCount: scope.boards.all().length,
        ),
        onSettingTap: (setting) =>
            mock('$setting no forma parte de este prototipo'),
        onPrivacyTap: () => context.push(Routes.privacy),
        onSignOut: () {
          scope.auth.signOut();
          context.go(Routes.onboarding);
        },
      ),
    );
  }
}
