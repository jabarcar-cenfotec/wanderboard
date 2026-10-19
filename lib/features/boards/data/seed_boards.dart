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
    note: 'home, but slower',
    coverPlaceId: 'arenal-bridges',
    featured: true,
  ),
  Board(
    id: BoardIds.kyoto,
    title: 'Kioto bajo la lluvia',
    note: 'umbrellas & maple leaves',
    coverPlaceId: 'philosophers-path',
  ),
  Board(
    id: BoardIds.viewpoints,
    title: 'Miradores tranquilos',
    note: 'go early, stay long',
    coverPlaceId: 'miradouro-graca',
  ),
  Board(
    id: BoardIds.coffee,
    title: 'Rincones de café',
    note: 'worth every detour',
    coverPlaceId: 'barrio-escalante',
  ),
];
