import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import '../../places/domain/place_repository.dart';

/// Editable state of the Add / Edit review form.
@immutable
class ReviewDraft {
  const ReviewDraft({
    this.placeId,
    this.name = '',
    this.city = '',
    this.country = '',
    this.photos = const [],
    this.rating = 0,
    this.note = '',
    this.boardIds = const [],
    this.tags = const [],
    this.visitedOn,
    this.status = PlaceStatus.wantToVisit,
    this.type,
    this.address = '',
    this.isSample = false,
  });

  factory ReviewDraft.fromPlace(Place place) {
    return ReviewDraft(
      placeId: place.id,
      name: place.name,
      city: place.city,
      country: place.country,
      photos: place.photos,
      rating: place.rating,
      note: place.note,
      boardIds: place.boardIds,
      tags: place.tags,
      visitedOn: place.visitedOn,
      status: place.status,
      type: place.type,
      address: place.address,
      isSample: place.isSample,
    );
  }

  /// Null for a new place.
  final String? placeId;
  final String name;
  final String city;
  final String country;
  final List<PlacePhoto> photos;
  final int rating;
  final String note;
  final List<String> boardIds;
  final List<String> tags;
  final DateTime? visitedOn;
  final PlaceStatus status;
  final PlaceType? type;
  final String address;
  final bool isSample;

  bool get isEditing => placeId != null;

  /// Only the name is required; everything else can be completed later.
  bool get canSave => name.trim().isNotEmpty;

  ReviewDraft copyWith({
    String? name,
    String? city,
    String? country,
    List<PlacePhoto>? photos,
    int? rating,
    String? note,
    List<String>? boardIds,
    PlaceStatus? status,
    DateTime? visitedOn,
    String? address,
    bool clearType = false,
    PlaceType? type,
  }) {
    return ReviewDraft(
      placeId: placeId,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      boardIds: boardIds ?? this.boardIds,
      tags: tags,
      visitedOn: visitedOn ?? this.visitedOn,
      status: status ?? this.status,
      type: clearType ? null : type ?? this.type,
      address: address ?? this.address,
      isSample: isSample,
    );
  }
}

/// Use case: turn a draft into a stored [Place].
class SaveReview {
  const SaveReview(this._places);

  final PlaceRepository _places;

  Place call(ReviewDraft draft, {DateTime? now}) {
    final city = draft.city.trim();
    final place = Place(
      id: draft.placeId ?? _places.nextId(),
      name: draft.name.trim(),
      city: city,
      country: draft.country.trim(),
      boardIds: draft.boardIds,
      rating: draft.rating.clamp(0, 5),
      note: draft.note.trim(),
      status: draft.status,
      visitedOn: draft.status.isPending
          ? null
          : draft.visitedOn ?? now ?? DateTime.now(),
      photos: draft.photos,
      tags: draft.tags,
      type: draft.type,
      address: draft.address.trim(),
      isSample: draft.isSample,
    );
    _places.save(place);
    return place;
  }
}
