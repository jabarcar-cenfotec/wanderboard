import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../domain/place_links.dart';
import 'place_detail_view.dart';

/// Container for a place and its private review.
class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.places,
      builder: (context, _) {
        final place = scope.places.byId(placeId);
        if (place == null) {
          return const Scaffold(
            body: Center(child: Text('Lugar no encontrado')),
          );
        }
        final boardTitles = [
          for (final id in place.boardIds) ?scope.boards.byId(id)?.title,
        ];

        return PlaceDetailView(
          place: place,
          boardTitles: boardTitles,
          onBack: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
          onEdit: () => context.push(Routes.editPlace(place.id)),
          onRegisterVisit: () => context.push(Routes.registerVisit(place.id)),
          onOpenGoogleMaps: () => launchUrl(googleMapsUrl(place)),
          onOpenWaze: () => launchUrl(wazeUrl(place)),
        );
      },
    );
  }
}
