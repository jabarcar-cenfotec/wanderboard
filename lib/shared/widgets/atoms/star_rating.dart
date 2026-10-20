import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Five stars plus the name of the chosen value (Fase 6, H4).
///
/// Read-only when [onChanged] is null; otherwise acts as a selector.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.onChanged});

  static const max = 5;
  static const labels = ['Malo', 'Regular', 'Bueno', 'Muy bueno', 'Excelente'];

  final int rating;
  final ValueChanged<int>? onChanged;

  /// "Muy bueno" for 4; empty when there is no rating.
  static String labelFor(int rating) =>
      rating < 1 || rating > max ? '' : labels[rating - 1];

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final c = tokens.colors;
    final size = tokens.sizes.ratingCircle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= max; i++)
          Semantics(
            label: i == 1 ? '1 estrella' : '$i estrellas',
            button: onChanged != null,
            selected: i <= rating,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: Padding(
                padding: EdgeInsets.only(right: tokens.spacing.xs),
                child: Icon(
                  i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: size,
                  color: i <= rating ? c.apricot : c.line,
                ),
              ),
            ),
          ),
        SizedBox(width: tokens.spacing.sm),
        Text(
          rating == 0 ? 'Sin valorar' : labelFor(rating),
          style: tokens.text.bodyStrong.copyWith(
            color: rating == 0 ? c.inkMuted : c.ink,
          ),
        ),
      ],
    );
  }
}
