import '../domain/board.dart';

abstract final class BoardIds {
  static const costaRica = 'costa-rica';
  static const coffee = 'coffee-corners';
  static const viewpoints = 'quiet-viewpoints';
  static const kyoto = 'kyoto-rain';
}

const seedBoards = [
  Board(
    id: BoardIds.costaRica,
    title: 'Costa Rica Slow Days',
    note: 'home, but slower',
    coverPlaceId: 'arenal-bridges',
    featured: true,
  ),
  Board(
    id: BoardIds.kyoto,
    title: 'Kyoto in the Rain',
    note: 'umbrellas & maple leaves',
    coverPlaceId: 'philosophers-path',
  ),
  Board(
    id: BoardIds.viewpoints,
    title: 'Quiet Viewpoints',
    note: 'go early, stay long',
    coverPlaceId: 'miradouro-graca',
  ),
  Board(
    id: BoardIds.coffee,
    title: 'Coffee Corners',
    note: 'worth every detour',
    coverPlaceId: 'barrio-escalante',
  ),
];
