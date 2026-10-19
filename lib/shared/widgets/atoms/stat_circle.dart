import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Stat variant of the rating circle: 56 px `card` circle with `shadowSoft`,
/// number in `titleL`, label below in `caption`.
class StatCircle extends StatelessWidget {
  const StatCircle({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final size = tokens.sizes.statCircle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.colors.card,
            boxShadow: tokens.shadowSoft,
          ),
          child: Text('$value', style: tokens.text.titleL),
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          label,
          style: tokens.text.caption.copyWith(color: tokens.colors.inkMuted),
        ),
      ],
    );
  }
}
