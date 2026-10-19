import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/molecules/wander_bottom_nav.dart';
import '../core/navigation/routes.dart';

/// Scaffold with the floating, blurred bottom navigation for top-level tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = location.startsWith(Routes.profile)
        ? WanderTab.profile
        : WanderTab.boards;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: WanderBottomNav(
        current: current,
        onBoards: () => context.go(Routes.home),
        onAdd: () => context.push(Routes.add),
        onProfile: () => context.go(Routes.profile),
      ),
    );
  }
}
