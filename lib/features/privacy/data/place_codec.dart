import '../../places/domain/place.dart';
import '../domain/encrypted_models.dart';

/// Converts places to the JSON that gets encrypted, and back.
abstract final class PlaceCodec {
  static Map<String, Object?> toJson(Place place) => {
    'id': place.id,
    'name': place.name,
    'city': place.city,
    'country': place.country,
    'boardIds': place.boardIds,
    'rating': place.rating,
    'note': place.note,
    'photos': [
      for (final photo in place.photos)
        {'seed': photo.seed, 'aspectRatio': photo.aspectRatio},
    ],
    'visitedOn': place.visitedOn?.toIso8601String(),
    'status': place.status.name,
    'tags': place.tags,
    'type': place.type?.name,
    'address': place.address,
    'isSample': place.isSample,
  };

  static Place fromJson(Map<String, Object?> json) {
    final visitedOn = json['visitedOn'] as String?;
    final type = json['type'] as String?;
    return Place(
      id: json['id']! as String,
      name: json['name']! as String,
      city: json['city']! as String,
      country: json['country']! as String,
      boardIds: List<String>.from(json['boardIds']! as List),
      rating: json['rating']! as int,
      note: json['note']! as String,
      photos: [
        for (final photo in json['photos']! as List)
          PlacePhoto(
            (photo as Map)['seed'] as String,
            aspectRatio: (photo['aspectRatio'] as num).toDouble(),
          ),
      ],
      visitedOn: visitedOn == null ? null : DateTime.parse(visitedOn),
      status: PlaceStatus.values.byName(json['status']! as String),
      tags: List<String>.from(json['tags']! as List),
      type: type == null ? null : PlaceType.values.byName(type),
      address: json['address']! as String,
      isSample: json['isSample']! as bool,
    );
  }

  static Map<String, Object?> sharedToJson(Place place, {required bool note}) =>
      {
        'name': place.name,
        'location': place.location,
        'rating': place.rating,
        'note': note ? place.note : '',
      };

  static SharedPlace sharedFromJson(Map<String, Object?> json) => SharedPlace(
    name: json['name']! as String,
    location: json['location']! as String,
    rating: json['rating']! as int,
    note: json['note']! as String,
  );
}
