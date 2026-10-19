import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../../places/presentation/place_list.dart';
import 'board_summary.dart';
import 'home_view.dart';

/// Container for "Mis lugares". The selected list lives in the URL
/// (`?lista=`), so saving a place can land on the right list; the search
/// text is local state.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String greetingFor(DateTime now) {
    if (now.hour < 12) return 'Buenos días';
    if (now.hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final list = PlaceList.fromSlug(
      GoRouterState.of(context).uri.queryParameters['lista'],
    );

    return ListenableBuilder(
      listenable: scope.places,
      builder: (context, _) {
        final boards = scope.boards
            .all()
            .map((board) => BoardSummary.of(board, scope.places))
            .toList();
        final all = scope.places.all();
        final places = _query.trim().isNotEmpty
            ? all.where((place) => placeMatches(place, _query)).toList()
            : all.where(list.includes).toList();

        return HomeView(
          greeting:
              '${HomeScreen.greetingFor(DateTime.now())}, '
              '${scope.profile.firstName}',
          placeCount: all.length,
          list: list,
          query: _query,
          places: places,
          boards: boards,
          onSelectList: (next) => context.go(Routes.myPlaces(next.slug)),
          onQueryChanged: (query) => setState(() => _query = query),
          onOpenPlace: (id) => context.push(Routes.place(id)),
          onOpenBoard: (id) => context.push(Routes.board(id)),
        );
      },
    );
  }
}
