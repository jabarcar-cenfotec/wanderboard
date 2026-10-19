import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import '../../places/domain/place_repository.dart';
import '../domain/board.dart';

/// View data for a board card: the board plus up to three collage photos.
@immutable
class BoardSummary {
  const BoardSummary({
    required this.board,
    required this.photoSeeds,
    required this.placeCount,
  });

  factory BoardSummary.of(Board board, PlaceRepository places) {
    final inBoard = places.inBoard(board.id);
    final cover = places.byId(board.coverPlaceId);
    final ordered = <Place>[?cover, ...inBoard.where((p) => p.id != cover?.id)];
    return BoardSummary(
      board: board,
      photoSeeds: ordered.take(3).map((p) => p.cover.seed).toList(),
      placeCount: inBoard.length,
    );
  }

  final Board board;
  final List<String> photoSeeds;
  final int placeCount;

  String get countLabel => placeCount == 1 ? '1 place' : '$placeCount places';
}
