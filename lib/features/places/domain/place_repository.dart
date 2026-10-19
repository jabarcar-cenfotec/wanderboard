import 'package:flutter/foundation.dart';

import 'place.dart';

/// Port for reading and saving places. Notifies listeners on change.
abstract class PlaceRepository extends ChangeNotifier {
  List<Place> all();

  Place? byId(String id);

  List<Place> inBoard(String boardId);

  /// Inserts or replaces a place.
  void save(Place place);

  String nextId();

  /// Id of the place saved most recently, consumed once for the drop-in motion.
  String? takeJustSavedId();
}
