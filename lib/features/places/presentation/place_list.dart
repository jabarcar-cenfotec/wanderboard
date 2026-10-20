import '../domain/place.dart';

/// The three ways to browse "Mis lugares" (CU-03).
enum PlaceList {
  pending('pendientes', 'Pendientes'),
  history('historial', 'Historial'),
  collections('colecciones', 'Colecciones');

  const PlaceList(this.slug, this.label);

  /// Value of the `lista` query parameter.
  final String slug;
  final String label;

  static PlaceList fromSlug(String? slug) =>
      values.firstWhere((list) => list.slug == slug, orElse: () => collections);

  /// List where a place with [status] is shown.
  static PlaceList of(PlaceStatus status) =>
      status.isPending ? pending : history;

  bool includes(Place place) => switch (this) {
    pending => place.status.isPending,
    history => !place.status.isPending,
    collections => false,
  };
}

/// Whether [place] matches a search [query] by name, type, address, city
/// or country, ignoring case and Spanish accents.
bool placeMatches(Place place, String query) {
  final needle = _fold(query.trim());
  if (needle.isEmpty) return true;
  return [
    place.name,
    place.type?.label ?? '',
    place.address,
    place.city,
    place.country,
  ].any((field) => _fold(field).contains(needle));
}

const _accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};

String _fold(String text) =>
    text.toLowerCase().split('').map((char) => _accents[char] ?? char).join();
