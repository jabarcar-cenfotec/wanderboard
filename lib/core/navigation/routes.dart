/// Route paths shared by the router and feature containers.
abstract final class Routes {
  static const onboarding = '/';
  static const home = '/home';
  static const profile = '/profile';
  static const add = '/add';

  static String board(String id) => '/boards/$id';
  static String place(String id) => '/places/$id';
  static String editPlace(String id) => '/places/$id/edit';
  static String addToBoard(String boardId) => '$add?board=$boardId';
}
