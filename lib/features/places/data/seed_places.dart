import '../../boards/data/seed_boards.dart';
import '../domain/place.dart';

/// Mock diary entries — a mix of Costa Rica and the rest of the world.
final List<Place> seedPlaces = [
  Place(
    id: 'arenal-bridges',
    name: 'Arenal Hanging Bridges',
    city: 'La Fortuna',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica, BoardIds.viewpoints],
    rating: 5,
    note:
        'Walked the bridges right after the rain stopped. Howler monkeys '
        'somewhere below us and the volcano finally showed its top for five '
        'minutes. Bring a light jacket and go before 8am.',
    visitedOn: DateTime(2025, 2, 8),
    photos: const [
      PlacePhoto('wb-arenal-1', aspectRatio: 0.75),
      PlacePhoto('wb-arenal-2', aspectRatio: 1.3),
      PlacePhoto('wb-arenal-3', aspectRatio: 1),
    ],
    tags: const ['hike', 'rainforest', 'early morning'],
  ),
  Place(
    id: 'monteverde',
    name: 'Monteverde Cloud Forest',
    city: 'Monteverde',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 4,
    note:
        'Everything dripping and green. We saw a quetzal thanks to a guide '
        'with a scope. The hummingbird garden near the entrance was the '
        'unexpected highlight.',
    visitedOn: DateTime(2025, 2, 10),
    photos: const [
      PlacePhoto('wb-monteverde-1', aspectRatio: 1),
      PlacePhoto('wb-monteverde-2', aspectRatio: 0.8),
    ],
    tags: const ['cloud forest', 'birds'],
  ),
  Place(
    id: 'playa-espadilla',
    name: 'Playa Espadilla',
    city: 'Manuel Antonio',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 4,
    note:
        'Warm water, sloth on the way in, and a pink sunset that did not '
        'look real. Crowded at noon — perfect after 4pm.',
    visitedOn: DateTime(2024, 12, 28),
    photos: const [
      PlacePhoto('wb-espadilla-1', aspectRatio: 0.66),
      PlacePhoto('wb-espadilla-2', aspectRatio: 1.25),
    ],
    tags: const ['beach', 'sunset'],
  ),
  Place(
    id: 'tortuguero',
    name: 'Tortuguero Canals',
    city: 'Tortuguero',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 5,
    note:
        'Silent boat at dawn through the canals. Caimans, herons, and a '
        'green turtle nest marked on the beach. No roads, only water.',
    visitedOn: DateTime(2024, 8, 17),
    photos: const [
      PlacePhoto('wb-tortuguero-1', aspectRatio: 1.1),
      PlacePhoto('wb-tortuguero-2', aspectRatio: 0.8),
    ],
    tags: const ['boat', 'wildlife'],
  ),
  Place(
    id: 'barrio-escalante',
    name: 'Barrio Escalante Coffee Walk',
    city: 'San José',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica, BoardIds.coffee],
    rating: 4,
    note:
        'Three cafés in one afternoon. The honey-processed pour-over at the '
        'corner place was the best. Streets feel calm on Sundays.',
    visitedOn: DateTime(2025, 5, 3),
    photos: const [
      PlacePhoto('wb-escalante-1', aspectRatio: 0.8),
      PlacePhoto('wb-escalante-2', aspectRatio: 1),
    ],
    tags: const ['coffee', 'city walk'],
  ),
  Place(
    id: 'miradouro-graca',
    name: 'Miradouro da Graça',
    city: 'Lisbon',
    country: 'Portugal',
    boardIds: const [BoardIds.viewpoints],
    rating: 5,
    note:
        'Took tram 28 up, stayed for golden hour under the pine trees. '
        'The whole city turns peach. Someone was playing fado nearby.',
    visitedOn: DateTime(2023, 10, 14),
    photos: const [
      PlacePhoto('wb-graca-1', aspectRatio: 1.3),
      PlacePhoto('wb-graca-2', aspectRatio: 0.75),
    ],
    tags: const ['viewpoint', 'golden hour'],
  ),
  Place(
    id: 'roma-norte',
    name: 'Roma Norte Café Morning',
    city: 'Mexico City',
    country: 'Mexico',
    boardIds: const [BoardIds.coffee],
    rating: 4,
    note:
        'Jacaranda season. Cortado and a conchita at a tiny counter café, '
        'then a slow walk to Parque México.',
    visitedOn: DateTime(2024, 3, 22),
    photos: const [
      PlacePhoto('wb-roma-1', aspectRatio: 0.7),
      PlacePhoto('wb-roma-2', aspectRatio: 1.2),
    ],
    tags: const ['coffee', 'pastries'],
  ),
  Place(
    id: 'degraves-street',
    name: 'Degraves Street',
    city: 'Melbourne',
    country: 'Australia',
    boardIds: const [BoardIds.coffee],
    rating: 3,
    note:
        'Lovely laneway, a bit touristy. The flat white lived up to the '
        'hype; the queue did not.',
    visitedOn: DateTime(2023, 1, 19),
    photos: const [
      PlacePhoto('wb-degraves-1', aspectRatio: 1),
      PlacePhoto('wb-degraves-2', aspectRatio: 0.8),
    ],
    tags: const ['laneway', 'coffee'],
  ),
  Place(
    id: 'arthurs-seat',
    name: "Arthur's Seat",
    city: 'Edinburgh',
    country: 'Scotland',
    boardIds: const [BoardIds.viewpoints],
    rating: 5,
    note:
        'Wind so strong we had to sit down at the top. Whole city and the '
        'sea in one look. Worth the muddy shoes.',
    visitedOn: DateTime(2023, 9, 2),
    photos: const [
      PlacePhoto('wb-arthurs-1', aspectRatio: 0.8),
      PlacePhoto('wb-arthurs-2', aspectRatio: 1.3),
    ],
    tags: const ['hike', 'windy'],
  ),
  Place(
    id: 'philosophers-path',
    name: "Philosopher's Path",
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto, BoardIds.viewpoints],
    rating: 5,
    note:
        'Light rain, red maples, almost nobody around at 7am. Stopped at a '
        'tiny tea house halfway. The quietest walk of the trip.',
    visitedOn: DateTime(2024, 11, 18),
    photos: const [
      PlacePhoto('wb-philosopher-1', aspectRatio: 0.75),
      PlacePhoto('wb-philosopher-2', aspectRatio: 1),
      PlacePhoto('wb-philosopher-3', aspectRatio: 1.3),
    ],
    tags: const ['walk', 'autumn', 'rain'],
  ),
  Place(
    id: 'arashiyama',
    name: 'Arashiyama Bamboo Grove',
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto],
    rating: 4,
    note:
        'The sound of the bamboo in the wind is the real reason to go. '
        'Arrive before sunrise or skip it.',
    visitedOn: DateTime(2024, 11, 20),
    photos: const [
      PlacePhoto('wb-arashiyama-1', aspectRatio: 0.66),
      PlacePhoto('wb-arashiyama-2', aspectRatio: 1),
    ],
    tags: const ['forest', 'sunrise'],
  ),
  Place(
    id: 'fushimi-inari',
    name: 'Fushimi Inari at Night',
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto],
    rating: 5,
    note:
        'Thousands of torii lit by small lanterns. We climbed halfway and '
        'only met cats. Slightly spooky, completely magical.',
    visitedOn: DateTime(2024, 11, 21),
    photos: const [
      PlacePhoto('wb-fushimi-1', aspectRatio: 1.2),
      PlacePhoto('wb-fushimi-2', aspectRatio: 0.8),
    ],
    tags: const ['night', 'shrine'],
  ),
];
