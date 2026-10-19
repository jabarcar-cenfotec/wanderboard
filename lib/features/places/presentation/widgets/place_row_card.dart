import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/pressable.dart';
import '../../domain/place.dart';
import 'place_polaroid_card.dart';
import 'status_badge.dart';

/// Compact row for the "Pendientes" and "Historial" lists.
class PlaceRowCard extends StatelessWidget {
  const PlaceRowCard({super.key, required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final thumb = s.xxxl + s.xl;

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Abrir ${place.name}',
      builder: (context, pressed) => Container(
        padding: EdgeInsets.all(s.md),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(tokens.radii.md),
          boxShadow: tokens.shadowSoft,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: thumb,
              child: PlaceImage(
                seed: place.cover.seed,
                borderRadius: BorderRadius.circular(tokens.radii.sm),
                pixelWidth: 200,
              ),
            ),
            SizedBox(width: s.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: tokens.text.bodyStrong),
                  if (place.location.isNotEmpty)
                    Text(
                      place.location,
                      style: tokens.text.caption.copyWith(color: c.inkMuted),
                    ),
                  SizedBox(height: s.sm),
                  Wrap(
                    spacing: s.sm,
                    runSpacing: s.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(status: place.status),
                      if (place.visitedOn != null)
                        Text(
                          polaroidCaption(place),
                          style: tokens.text.caption.copyWith(
                            color: c.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
