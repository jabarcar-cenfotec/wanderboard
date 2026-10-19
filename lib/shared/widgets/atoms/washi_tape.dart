import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// 64×20 strip of washi tape, rotated ±8° (DESIGN.md §5).
///
/// Use at most one per card and only on featured/cover items.
class WashiTape extends StatelessWidget {
  const WashiTape({super.key, this.leanRight = false});

  final bool leanRight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final angle = tokens.motion.washiAngleDegrees * (leanRight ? 1 : -1);

    return Transform.rotate(
      angle: tokens.motion.radians(angle),
      child: Container(
        width: tokens.sizes.washiTape.width,
        height: tokens.sizes.washiTape.height,
        decoration: BoxDecoration(
          color: tokens.colors.tape,
          borderRadius: BorderRadius.circular(tokens.spacing.xs / 2),
        ),
      ),
    );
  }
}

/// Places a [WashiTape] overlapping the top edge of [child].
class Taped extends StatelessWidget {
  const Taped({super.key, required this.child, this.leanRight = false});

  final Widget child;
  final bool leanRight;

  @override
  Widget build(BuildContext context) {
    final tape = context.wander.sizes.washiTape;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -tape.height / 2,
          left: 0,
          right: 0,
          child: Center(child: WashiTape(leanRight: leanRight)),
        ),
      ],
    );
  }
}
