import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import 'board_summary.dart';
import 'home_view.dart';

/// Container for "My boards".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String greetingFor(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.places,
      builder: (context, _) {
        final boards = scope.boards
            .all()
            .map((board) => BoardSummary.of(board, scope.places))
            .toList();

        return HomeView(
          greeting:
              '${greetingFor(DateTime.now())}, ${scope.profile.firstName}',
          placeCount: scope.places.all().length,
          boards: boards,
          onOpenBoard: (id) => context.push(Routes.board(id)),
        );
      },
    );
  }
}
