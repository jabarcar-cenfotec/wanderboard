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
    title: 'Costa Rica sin prisa',
    note: 'en casa, pero sin prisa',
    coverPlaceId: 'arenal-bridges',
    featured: true,
  ),
  Board(
    id: BoardIds.kyoto,
    title: 'Kioto bajo la lluvia',
    note: 'paraguas y hojas de arce',
    coverPlaceId: 'philosophers-path',
  ),
  Board(
    id: BoardIds.viewpoints,
    title: 'Miradores tranquilos',
    note: 'llegar temprano, quedarse mucho',
    coverPlaceId: 'miradouro-graca',
  ),
  Board(
    id: BoardIds.coffee,
    title: 'Rincones de café',
    note: 'valen cada desvío',
    coverPlaceId: 'barrio-escalante',
  ),
];
