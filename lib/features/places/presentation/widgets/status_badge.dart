import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/icons/wander_icons.dart';
import '../../domain/place.dart';

/// Read-only label of a place's status. Unlike [TagChip] it is not a
/// control: no checkmark, no tap, one color per status.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final PlaceStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final c = tokens.colors;
    final (IconData icon, Color tint) = switch (status) {
      PlaceStatus.wantToVisit => (WanderIcons.bookmark, c.slate),
      PlaceStatus.visited => (WanderIcons.check, c.success),
      PlaceStatus.wantToReturn => (WanderIcons.heart, c.apricot),
      PlaceStatus.wouldNotReturn => (WanderIcons.close, c.inkMuted),
    };

    return Semantics(
      label: 'Estado: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(tokens.radii.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: tokens.spacing.md + 2, color: tint),
            SizedBox(width: tokens.spacing.xs),
            Text(
              status.label,
              style: tokens.text.caption.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}
