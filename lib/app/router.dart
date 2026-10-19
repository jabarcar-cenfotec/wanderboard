import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/onboarding_screen.dart';
import '../features/boards/presentation/board_detail_screen.dart';
import '../features/boards/presentation/home_screen.dart';
import '../features/places/presentation/place_detail_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/reviews/presentation/review_editor_screen.dart';
import '../core/navigation/routes.dart';
import 'home_shell.dart';

GoRouter createRouter() {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.onboarding,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            HomeShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/boards/:boardId',
        builder: (context, state) =>
            BoardDetailScreen(boardId: state.pathParameters['boardId']!),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/places/:placeId',
        builder: (context, state) =>
            PlaceDetailScreen(placeId: state.pathParameters['placeId']!),
        routes: [
          GoRoute(
            parentNavigatorKey: rootKey,
            path: 'edit',
            builder: (context, state) =>
                ReviewEditorScreen(placeId: state.pathParameters['placeId']),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: Routes.add,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: ReviewEditorScreen(
            initialBoardId: state.uri.queryParameters['board'],
          ),
        ),
      ),
    ],
  );
}
