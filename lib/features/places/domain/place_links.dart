import 'place.dart';

/// Text used to look the place up in a maps app.
String mapsQuery(Place place) => [
  place.name,
  place.address,
  place.city,
  place.country,
].where((part) => part.trim().isNotEmpty).join(', ');

/// Google Maps search for [place] (Fase 6, H5).
Uri googleMapsUrl(Place place) => Uri.https('www.google.com', '/maps/search/', {
  'api': '1',
  'query': mapsQuery(place),
});

/// Waze search for [place] that starts navigation.
Uri wazeUrl(Place place) =>
    Uri.https('waze.com', '/ul', {'q': mapsQuery(place), 'navigate': 'yes'});
