import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/atoms/drop_in.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/pressable.dart';
import '../../../../shared/widgets/atoms/tilted_item.dart';
import '../../../../shared/widgets/molecules/polaroid_frame.dart';
import '../../domain/place.dart';

String placePhotoHeroTag(String placeId) => 'place-photo-$placeId';

/// Grid place card: tilted polaroid with the visit date in the strip,
/// name in `titleM`, city in `caption`. Photo is a [Hero] source.
class PlacePolaroidCard extends StatelessWidget {
  const PlacePolaroidCard({
    super.key,
    required this.place,
    required this.onTap,
    this.dropIn = false,
  });

  final Place place;
  final VoidCallback onTap;

  /// Plays the "new item saved" drop-in instead of a static tilt.
  final bool dropIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final angle = TiltedItem.radiansFor(context, place.id);

    final card = Pressable(
      onTap: onTap,
      semanticLabel: 'Open ${place.name}',
      builder: (context, pressed) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PolaroidFrame(
            lifted: pressed,
            caption: formatShortDate(place.visitedOn),
            photo: Hero(
              tag: placePhotoHeroTag(place.id),
              child: PlaceImage(
                seed: place.cover.seed,
                aspectRatio: place.cover.aspectRatio,
                pixelWidth: 400,
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.text.titleM,
                ),
                Text(
                  place.city,
                  style: tokens.text.caption.copyWith(
                    color: tokens.colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (dropIn) return DropIn(finalAngle: angle, child: card);
    return Transform.rotate(angle: angle, child: card);
  }
}
