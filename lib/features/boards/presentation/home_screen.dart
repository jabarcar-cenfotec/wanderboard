import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../../places/domain/place.dart';
import '../../places/presentation/place_list.dart';
import 'board_summary.dart';
import 'home_view.dart';

/// Container for "Mis lugares". The selected list lives in the URL
/// (`?lista=`), so saving a place can land on the right list; the search
/// text and the type filter are local state.
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
  PlaceType? _type;

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
        // H11: the search and the type filter narrow the active list;
        // from "Colecciones" the search looks at every place.
        final browsing = list != PlaceList.collections;
        final places = all
            .where((place) => !browsing || list.includes(place))
            .where((place) => !browsing || _type == null || place.type == _type)
            .where((place) => placeMatches(place, _query))
            .toList();

        return HomeView(
          greeting:
              '${HomeScreen.greetingFor(DateTime.now())}, '
              '${scope.auth.name}',
          placeCount: all.length,
          list: list,
          query: _query,
          type: _type,
          places: places,
          boards: boards,
          onSelectList: (next) => context.go(Routes.myPlaces(next.slug)),
          onQueryChanged: (query) => setState(() => _query = query),
          onTypeChanged: (type) => setState(() => _type = type),
          onOpenPlace: (id) => context.push(Routes.place(id)),
          onOpenBoard: (id) => context.push(Routes.board(id)),
        );
      },
    );
  }
}
