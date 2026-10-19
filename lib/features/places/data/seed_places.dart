import '../../boards/data/seed_boards.dart';
import '../domain/place.dart';

/// Mock diary entries — pending places plus visits in Costa Rica and abroad.
final List<Place> seedPlaces = [
  Place(
    id: 'catarata-del-toro',
    name: 'Catarata del Toro',
    city: 'Bajos del Toro',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 0,
    note: 'Me la recomendaron en el trabajo. Ir temprano y con zapatos para barro.',
    status: PlaceStatus.wantToVisit,
    photos: const [PlacePhoto('id:15', aspectRatio: 0.75)],
    tags: const ['catarata'],
  ),
  Place(
    id: 'volcan-irazu',
    name: 'Volcán Irazú',
    city: 'Cartago',
    country: 'Costa Rica',
    boardIds: const [BoardIds.viewpoints],
    rating: 0,
    note: 'Dicen que en días despejados se ven los dos océanos.',
    status: PlaceStatus.wantToVisit,
    photos: const [PlacePhoto('id:177', aspectRatio: 1.2)],
    tags: const ['volcán', 'mirador'],
  ),
  Place(
    id: 'mercado-central',
    name: 'Mercado Central',
    city: 'San José',
    country: 'Costa Rica',
    boardIds: const [],
    rating: 0,
    note: '',
    status: PlaceStatus.wantToVisit,
    photos: const [],
  ),
  Place(
    id: 'arenal-bridges',
    name: 'Puentes Colgantes del Arenal',
    city: 'La Fortuna',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica, BoardIds.viewpoints],
    rating: 5,
    note:
        'Caminamos los puentes justo cuando paró la lluvia. Monos congo abajo y '
        'el volcán por fin mostró la cima cinco minutos. Llevar una chaqueta '
        'liviana e ir antes de las 8 a. m.',
    visitedOn: DateTime(2025, 2, 8),
    photos: const [
      PlacePhoto('id:316', aspectRatio: 0.75),
      PlacePhoto('id:28', aspectRatio: 1.3),
      PlacePhoto('id:189', aspectRatio: 1),
    ],
    tags: const ['caminata', 'bosque lluvioso', 'madrugada'],
  ),
  Place(
    id: 'monteverde',
    name: 'Bosque Nuboso de Monteverde',
    city: 'Monteverde',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 4,
    note:
        'Todo goteando y verde. Vimos un quetzal gracias a un guía con '
        'telescopio. El jardín de colibríes cerca de la entrada fue la sorpresa '
        'del día.',
    visitedOn: DateTime(2025, 2, 10),
    photos: const [
      PlacePhoto('id:229', aspectRatio: 1),
      PlacePhoto('id:353', aspectRatio: 0.8),
    ],
    tags: const ['bosque nuboso', 'aves'],
  ),
  Place(
    id: 'playa-espadilla',
    name: 'Playa Espadilla',
    city: 'Manuel Antonio',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 4,
    note:
        'Agua tibia, un perezoso en el camino y un atardecer rosado que parecía '
        'irreal. Llena al mediodía; perfecta después de las 4 p. m.',
    visitedOn: DateTime(2024, 12, 28),
    status: PlaceStatus.wantToReturn,
    photos: const [
      PlacePhoto('id:215', aspectRatio: 0.66),
      PlacePhoto('id:374', aspectRatio: 1.25),
    ],
    tags: const ['playa', 'atardecer'],
  ),
  Place(
    id: 'tortuguero',
    name: 'Canales de Tortuguero',
    city: 'Tortuguero',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica],
    rating: 5,
    note:
        'Bote en silencio al amanecer por los canales. Caimanes, garzas y un nido '
        'de tortuga verde marcado en la playa. Sin calles, solo agua.',
    visitedOn: DateTime(2024, 8, 17),
    status: PlaceStatus.wantToReturn,
    photos: const [
      PlacePhoto('id:124', aspectRatio: 1.1),
      PlacePhoto('id:217', aspectRatio: 0.8),
    ],
    tags: const ['bote', 'fauna'],
  ),
  Place(
    id: 'barrio-escalante',
    name: 'Ruta de café en Barrio Escalante',
    city: 'San José',
    country: 'Costa Rica',
    boardIds: const [BoardIds.costaRica, BoardIds.coffee],
    rating: 4,
    note:
        'Tres cafés en una tarde. El filtrado de proceso honey del local de la '
        'esquina fue el mejor. Los domingos las calles están tranquilas.',
    visitedOn: DateTime(2025, 5, 3),
    photos: const [
      PlacePhoto('id:42', aspectRatio: 0.8),
      PlacePhoto('id:30', aspectRatio: 1),
    ],
    tags: const ['café', 'paseo urbano'],
  ),
  Place(
    id: 'miradouro-graca',
    name: 'Miradouro da Graça',
    city: 'Lisbon',
    country: 'Portugal',
    boardIds: const [BoardIds.viewpoints],
    rating: 5,
    note:
        'Subimos en el tranvía 28 y nos quedamos a la hora dorada bajo los pinos. '
        'Toda la ciudad se vuelve color durazno. Alguien tocaba fado cerca.',
    visitedOn: DateTime(2023, 10, 14),
    photos: const [
      PlacePhoto('id:288', aspectRatio: 1.3),
      PlacePhoto('id:188', aspectRatio: 0.75),
    ],
    tags: const ['mirador', 'hora dorada'],
  ),
  Place(
    id: 'roma-norte',
    name: 'Mañana de café en la Roma Norte',
    city: 'Mexico City',
    country: 'Mexico',
    boardIds: const [BoardIds.coffee],
    rating: 4,
    note:
        'Temporada de jacarandas. Un cortado y una concha en una barra diminuta, '
        'y luego una caminata lenta al Parque México.',
    visitedOn: DateTime(2024, 3, 22),
    photos: const [
      PlacePhoto('id:163', aspectRatio: 0.7),
      PlacePhoto('id:365', aspectRatio: 1.2),
    ],
    tags: const ['café', 'repostería'],
  ),
  Place(
    id: 'degraves-street',
    name: 'Calle Degraves',
    city: 'Melbourne',
    country: 'Australia',
    boardIds: const [BoardIds.coffee],
    rating: 3,
    note:
        'Callejón bonito, pero muy turístico. El flat white cumplió; la fila no. '
        'No volvería a hacer esa espera.',
    visitedOn: DateTime(2023, 1, 19),
    status: PlaceStatus.wouldNotReturn,
    photos: const [
      PlacePhoto('id:322', aspectRatio: 1),
      PlacePhoto('id:351', aspectRatio: 0.8),
    ],
    tags: const ['callejón', 'café'],
  ),
  Place(
    id: 'arthurs-seat',
    name: "Arthur's Seat",
    city: 'Edinburgh',
    country: 'Scotland',
    boardIds: const [BoardIds.viewpoints],
    rating: 5,
    note:
        'Tanto viento que tuvimos que sentarnos en la cima. Toda la ciudad y el '
        'mar de un vistazo. Valió los zapatos embarrados.',
    visitedOn: DateTime(2023, 9, 2),
    photos: const [
      PlacePhoto('id:198', aspectRatio: 0.8),
      PlacePhoto('id:287', aspectRatio: 1.3),
    ],
    tags: const ['caminata', 'viento'],
  ),
  Place(
    id: 'philosophers-path',
    name: 'Camino del Filósofo',
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto, BoardIds.viewpoints],
    rating: 5,
    note:
        'Llovizna, arces rojos y casi nadie a las 7 a. m. Paramos en una casa de '
        'té diminuta a medio camino. La caminata más tranquila del viaje.',
    visitedOn: DateTime(2024, 11, 18),
    photos: const [
      PlacePhoto('id:301', aspectRatio: 0.75),
      PlacePhoto('id:190', aspectRatio: 1),
      PlacePhoto('id:167', aspectRatio: 1.3),
    ],
    tags: const ['paseo', 'otoño', 'lluvia'],
  ),
  Place(
    id: 'arashiyama',
    name: 'Bosque de bambú de Arashiyama',
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto],
    rating: 4,
    note:
        'El sonido del bambú con el viento es la verdadera razón para ir. Llegar '
        'antes del amanecer o no ir.',
    visitedOn: DateTime(2024, 11, 20),
    photos: const [
      PlacePhoto('id:254', aspectRatio: 0.66),
      PlacePhoto('id:186', aspectRatio: 1),
    ],
    tags: const ['bosque', 'amanecer'],
  ),
  Place(
    id: 'fushimi-inari',
    name: 'Fushimi Inari de noche',
    city: 'Kyoto',
    country: 'Japan',
    boardIds: const [BoardIds.kyoto],
    rating: 5,
    note:
        'Miles de torii iluminados con faroles pequeños. Subimos hasta la mitad y '
        'solo nos topamos gatos. Un poco tétrico, totalmente mágico.',
    visitedOn: DateTime(2024, 11, 21),
    photos: const [
      PlacePhoto('id:232', aspectRatio: 1.2),
      PlacePhoto('id:195', aspectRatio: 0.8),
    ],
    tags: const ['noche', 'santuario'],
  ),
];
