import 'package:flutter/foundation.dart';

/// A themed collection of places (Pinterest-style board).
@immutable
class Board {
  const Board({
    required this.id,
    required this.title,
    required this.note,
    required this.coverPlaceId,
    this.featured = false,
  });

  final String id;
  final String title;

  /// Short personal subtitle, rendered as a handwritten note.
  final String note;
  final String coverPlaceId;

  /// Featured boards may carry the single washi-tape accent.
  final bool featured;
}

/// Port for reading boards.
abstract interface class BoardRepository {
  List<Board> all();

  Board? byId(String id);
}
