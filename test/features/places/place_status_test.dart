import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/data/in_memory_place_repository.dart';
import 'package:wanderboard/features/places/domain/place.dart';
import 'package:wanderboard/features/reviews/domain/review_draft.dart';

void main() {
  group('PlaceStatus', () {
    test('uses the state names defined for the prototype', () {
      expect(PlaceStatus.values.map((s) => s.label), [
        'Quiero visitar',
        'Ya visité',
        'Quiero volver',
        'No volvería',
      ]);
    });

    test('only "Quiero visitar" is pending', () {
      expect(PlaceStatus.wantToVisit.isPending, isTrue);
      expect(PlaceStatus.values.where((s) => s.isPending), [
        PlaceStatus.wantToVisit,
      ]);
    });
  });

  group('ReviewDraft', () {
    test('a new place can be saved with only its name', () {
      const draft = ReviewDraft(name: 'Catarata del Toro');

      expect(draft.canSave, isTrue);
      expect(draft.status, PlaceStatus.wantToVisit);
    });

    test('a draft without a name cannot be saved', () {
      expect(const ReviewDraft(name: '  ').canSave, isFalse);
    });
  });

  group('SaveReview', () {
    final now = DateTime(2026, 10, 19);

    test('a pending place is stored without visit date or rating', () {
      final places = InMemoryPlaceRepository(seed: const []);

      final place = SaveReview(places)(
        const ReviewDraft(name: 'Catarata del Toro'),
        now: now,
      );

      expect(place.status, PlaceStatus.wantToVisit);
      expect(place.visitedOn, isNull);
      expect(place.rating, 0);
      expect(places.byId(place.id), place);
    });

    test('registering a visit stores the status and the visit date', () {
      final places = InMemoryPlaceRepository(seed: const []);
      final pending = SaveReview(places)(
        const ReviewDraft(name: 'Volcán Irazú'),
        now: now,
      );

      final visited = SaveReview(places)(
        ReviewDraft.fromPlace(pending).copyWith(
          status: PlaceStatus.visited,
          note: 'Frío, pero valió la pena.',
          rating: 4,
        ),
        now: now,
      );

      expect(visited.id, pending.id);
      expect(visited.status, PlaceStatus.visited);
      expect(visited.visitedOn, now);
      expect(visited.note, 'Frío, pero valió la pena.');
      expect(visited.rating, 4);
      expect(places.all(), hasLength(1));
    });
  });

  test('a place without photos gets a placeholder cover', () {
    const place = Place(
      id: 'p1',
      name: 'Mercado Central',
      city: '',
      country: '',
      boardIds: [],
      rating: 0,
      note: '',
      photos: [],
    );

    expect(place.cover.seed, isEmpty);
  });
}
