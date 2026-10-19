import '../domain/place.dart';
import '../domain/place_repository.dart';
import 'seed_places.dart';

/// Mock repository backed by an in-memory list (no persistence).
class InMemoryPlaceRepository extends PlaceRepository {
  InMemoryPlaceRepository({List<Place>? seed})
    : _places = List.of(seed ?? seedPlaces);

  final List<Place> _places;
  String? _justSavedId;
  int _counter = 0;

  @override
  List<Place> all() => List.unmodifiable(_places);

  @override
  Place? byId(String id) {
    for (final place in _places) {
      if (place.id == id) return place;
    }
    return null;
  }

  @override
  List<Place> inBoard(String boardId) =>
      _places.where((p) => p.boardIds.contains(boardId)).toList();

  @override
  void save(Place place) {
    final index = _places.indexWhere((p) => p.id == place.id);
    if (index == -1) {
      _places.insert(0, place);
    } else {
      _places[index] = place;
    }
    _justSavedId = place.id;
    notifyListeners();
  }

  @override
  String nextId() => 'new-${++_counter}';

  @override
  String? takeJustSavedId() {
    final id = _justSavedId;
    _justSavedId = null;
    return id;
  }
}
