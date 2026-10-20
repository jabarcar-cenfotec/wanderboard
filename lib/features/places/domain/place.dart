import 'package:flutter/foundation.dart';

/// A photo reference. [seed] resolves to a mock image; [aspectRatio] is
/// width / height and drives the masonry layout.
@immutable
class PlacePhoto {
  const PlacePhoto(this.seed, {this.aspectRatio = 0.8});

  /// No photo yet: rendered as a neutral placeholder.
  static const none = PlacePhoto('');

  final String seed;
  final double aspectRatio;
}

/// Personal state of a place, as named in the Fase 3 userflows.
enum PlaceStatus {
  wantToVisit('Quiero visitar'),
  visited('Ya visité'),
  wantToReturn('Quiero volver'),
  wouldNotReturn('No volvería');

  const PlaceStatus(this.label);

  final String label;

  /// Pending places have not been visited yet.
  bool get isPending => this == wantToVisit;
}

/// Kind of place, used to filter and search (Fase 6, H2).
enum PlaceType {
  restaurant('Restaurante'),
  cafe('Café'),
  nature('Naturaleza'),
  viewpoint('Mirador'),
  culture('Cultura'),
  other('Otro');

  const PlaceType(this.label);

  final String label;
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
    required this.photos,
    this.visitedOn,
    this.status = PlaceStatus.visited,
    this.tags = const [],
    this.type,
    this.address = '',
    this.isSample = false,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final List<String> boardIds;

  /// 1–5, shown as rating circles; 0 when there is no rating yet.
  final int rating;

  /// Private note; never shared unless the user opts in.
  final String note;

  /// Null while the place is pending.
  final DateTime? visitedOn;
  final PlaceStatus status;
  final List<PlacePhoto> photos;
  final List<String> tags;

  /// Null when the user did not choose one.
  final PlaceType? type;

  /// Free-text address, used to open the place in a maps app.
  final String address;

  /// Preloaded example entry, labeled as such in the lists.
  final bool isSample;

  /// First photo, or [PlacePhoto.none] when there are no photos yet.
  PlacePhoto get cover => photos.isNotEmpty ? photos.first : PlacePhoto.none;

  String get location =>
      [city, country].where((part) => part.trim().isNotEmpty).join(', ');

  /// Type and location, e.g. "Restaurante · Heredia, Costa Rica".
  String get subtitle =>
      [?type?.label, location].where((part) => part.isNotEmpty).join(' · ');

  Place copyWith({
    String? name,
    String? city,
    String? country,
    List<String>? boardIds,
    int? rating,
    String? note,
    DateTime? visitedOn,
    PlaceStatus? status,
    List<PlacePhoto>? photos,
    List<String>? tags,
    PlaceType? type,
    String? address,
    bool? isSample,
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
      status: status ?? this.status,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      address: address ?? this.address,
      isSample: isSample ?? this.isSample,
    );
  }
}
