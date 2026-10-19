import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../../share/presentation/share_board_sheet.dart';
import 'board_detail_view.dart';
import 'board_summary.dart';

/// Container for a single board.
class BoardDetailScreen extends StatefulWidget {
  const BoardDetailScreen({super.key, required this.boardId});

  final String boardId;

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  String? _dropInId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _dropInId = AppScope.of(context).places.takeJustSavedId();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final board = scope.boards.byId(widget.boardId);

    if (board == null) {
      return const Scaffold(body: Center(child: Text('Board not found')));
    }

    return ListenableBuilder(
      listenable: scope.places,
      builder: (context, _) {
        final summary = BoardSummary.of(board, scope.places);
        return BoardDetailView(
          summary: summary,
          places: scope.places.inBoard(board.id),
          dropInId: _dropInId,
          onBack: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
          onShare: () => showShareBoardSheet(context, summary),
          onOpenPlace: (id) => context.push(Routes.place(id)),
          onAddPlace: () => context.push(Routes.addToBoard(board.id)),
        );
      },
    );
  }
}
