import 'package:flutter/foundation.dart';

/// A photo reference. [seed] resolves to a mock image; [aspectRatio] is
/// width / height and drives the masonry layout.
@immutable
class PlacePhoto {
  const PlacePhoto(this.seed, {this.aspectRatio = 0.8});

  final String seed;
  final double aspectRatio;
}

/// A place in the diary together with its private review.
@immutable
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.boardIds,
    required this.rating,
    required this.note,
    required this.visitedOn,
    required this.photos,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final List<String> boardIds;

  /// 1–5, shown as rating circles.
  final int rating;

  /// Private note; never shared unless the user opts in.
  final String note;
  final DateTime visitedOn;
  final List<PlacePhoto> photos;
  final List<String> tags;

  PlacePhoto get cover => photos.first;

  String get location => '$city, $country';

  Place copyWith({
    String? name,
    String? city,
    String? country,
    List<String>? boardIds,
    int? rating,
    String? note,
    DateTime? visitedOn,
    List<PlacePhoto>? photos,
    List<String>? tags,
  }) {
    return Place(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      boardIds: boardIds ?? this.boardIds,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      visitedOn: visitedOn ?? this.visitedOn,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
    );
  }
}
