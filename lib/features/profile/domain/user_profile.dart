import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.motto,
    required this.avatarSeed,
  });

  final String name;
  final String email;

  /// Short handwritten line under the name.
  final String motto;
  final String avatarSeed;

  String get firstName => name.split(' ').first;

  /// Same profile under the name typed at onboarding, without the demo email.
  UserProfile named(String name) =>
      UserProfile(name: name, email: '', motto: motto, avatarSeed: avatarSeed);
}

/// Personal totals only — no public counts (DESIGN.md §1).
@immutable
class DiaryStats {
  const DiaryStats({
    required this.places,
    required this.boards,
    required this.cities,
  });

  factory DiaryStats.from({
    required List<Place> places,
    required int boardCount,
  }) {
    final cities = places.map((p) => '${p.city}|${p.country}').toSet();
    return DiaryStats(
      places: places.length,
      boards: boardCount,
      cities: cities.length,
    );
  }

  final int places;
  final int boards;
  final int cities;
}
