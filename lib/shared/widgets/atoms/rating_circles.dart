import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Five rating circles that replace stars (DESIGN.md §6).
///
/// Read-only when [onChanged] is null; otherwise acts as a selector.
class RatingCircles extends StatelessWidget {
  const RatingCircles({
    super.key,
    required this.rating,
    this.onChanged,
    this.max = 5,
    this.size,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final int max;

  /// Defaults to the 36 px token.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final diameter = size ?? tokens.sizes.ratingCircle;
    final gap = diameter <= tokens.spacing.lg
        ? tokens.spacing.xs
        : tokens.spacing.sm;

    return Semantics(
      label: 'Valoración $rating de $max',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max; i++) ...[
            if (i > 0) SizedBox(width: gap),
            RatingCircle(
              filled: i < rating,
              size: diameter,
              onTap: onChanged == null ? null : () => onChanged!(i + 1),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single circle: `apricot` when filled, `card` with `line` border when empty.
class RatingCircle extends StatelessWidget {
  const RatingCircle({
    super.key,
    required this.filled,
    required this.size,
    this.onTap,
  });

  final bool filled;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final circle = AnimatedContainer(
      duration: tokens.motion.fast,
      curve: tokens.motion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? tokens.colors.apricot : tokens.colors.card,
        border: Border.all(
          color: filled ? tokens.colors.apricot : tokens.colors.line,
          width: tokens.sizes.ghostBorder,
        ),
      ),
    );

    if (onTap == null) return circle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: circle,
    );
  }
}
