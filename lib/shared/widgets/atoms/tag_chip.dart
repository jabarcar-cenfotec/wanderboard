import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../icons/wander_icons.dart';

/// Tag / selectable chip: `peach` @ 45%, `ink` caption, radius `rSm`, h 32.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final c = tokens.colors;
    final fill = selected
        ? c.peach
        : c.peach.withValues(alpha: tokens.sizes.chipFillOpacity);

    final chip = AnimatedContainer(
      duration: tokens.motion.fast,
      curve: tokens.motion.curve,
      height: tokens.sizes.chipHeight,
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.radii.sm),
        border: Border.all(
          color: selected ? c.apricot : fill,
          width: tokens.sizes.ghostBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            Icon(WanderIcons.check, size: tokens.spacing.lg, color: c.ink),
            SizedBox(width: tokens.spacing.xs),
          ],
          Text(label, style: tokens.text.caption.copyWith(color: c.ink)),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }
}
