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
