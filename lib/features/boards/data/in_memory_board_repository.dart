import '../domain/board.dart';
import 'seed_boards.dart';

/// Mock board repository over const seed data.
class InMemoryBoardRepository implements BoardRepository {
  const InMemoryBoardRepository({this.boards = seedBoards});

  final List<Board> boards;

  @override
  List<Board> all() => boards;

  @override
  Board? byId(String id) {
    for (final board in boards) {
      if (board.id == id) return board;
    }
    return null;
  }
}
