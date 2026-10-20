import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/domain/place.dart';
import 'package:wanderboard/features/places/domain/place_links.dart';
import 'package:wanderboard/features/places/presentation/place_list.dart';

void main() {
  const place = Place(
    id: 'soda',
    name: 'Soda La Casona',
    city: 'Heredia',
    country: 'Costa Rica',
    address: '200 m norte de la iglesia',
    type: PlaceType.restaurant,
    boardIds: [],
    rating: 0,
    note: '',
    photos: [],
    status: PlaceStatus.wantToVisit,
  );

  test('Google Maps link searches name, address, city and country', () {
    expect(
      googleMapsUrl(place).toString(),
      'https://www.google.com/maps/search/?api=1&query='
      'Soda+La+Casona%2C+200+m+norte+de+la+iglesia%2C+Heredia%2C+Costa+Rica',
    );
  });

  test('Waze link searches the same text and starts navigation', () {
    final url = wazeUrl(place);
    expect(url.host, 'waze.com');
    expect(
      url.queryParameters['q'],
      'Soda La Casona, 200 m norte de la iglesia, Heredia, Costa Rica',
    );
    expect(url.queryParameters['navigate'], 'yes');
  });

  test('search matches the place type, ignoring accents', () {
    expect(placeMatches(place, 'restaurante'), isTrue);
    expect(placeMatches(place.copyWith(type: PlaceType.cafe), 'cafe'), isTrue);
    expect(placeMatches(place, 'mirador'), isFalse);
  });
}
