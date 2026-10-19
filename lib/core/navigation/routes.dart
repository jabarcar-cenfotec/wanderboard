/// Route paths shared by the router and feature containers.
abstract final class Routes {
  static const onboarding = '/';
  static const home = '/home';
  static const profile = '/profile';
  static const add = '/add';

  /// "Mis lugares" opened on one of its lists (`pendientes`, `historial`, `colecciones`).
  static String myPlaces(String list) => '$home?lista=$list';

  static String board(String id) => '/boards/$id';
  static String place(String id) => '/places/$id';
  static String editPlace(String id) => '/places/$id/edit';
  static String registerVisit(String id) => '/places/$id/edit?visita=1';
  static String addToBoard(String boardId) => '$add?board=$boardId';
}
