import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../core/utils/stable_tilt.dart';

/// Rotates [child] by a stable tilt in {-2°..2°} seeded by [id].
///
/// Grids only — never use in detail views (DESIGN.md §5).
class TiltedItem extends StatelessWidget {
  const TiltedItem({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  static double radiansFor(BuildContext context, String id) {
    final motion = context.wander.motion;
    return motion.radians(stableTiltDegrees(id, motion.tiltSteps));
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(angle: radiansFor(context, id), child: child);
  }
}
