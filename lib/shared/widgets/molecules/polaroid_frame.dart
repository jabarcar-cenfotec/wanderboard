import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Polaroid frame (DESIGN.md §5): 8 px sides, 28 px bottom strip,
/// `rPolaroid` radius and `shadowSoft` (or `shadowLift` when [lifted]).
class PolaroidFrame extends StatelessWidget {
  const PolaroidFrame({
    super.key,
    required this.photo,
    this.caption,
    this.lifted = false,
  });

  final Widget photo;

  /// Optional `handNote` text shown in the bottom strip.
  final String? caption;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final side = tokens.sizes.polaroidSide;
    final bottom = tokens.sizes.polaroidBottom;

    return AnimatedContainer(
      duration: tokens.motion.fast,
      curve: tokens.motion.curve,
      decoration: BoxDecoration(
        color: tokens.colors.polaroid,
        borderRadius: BorderRadius.circular(tokens.radii.polaroid),
        boxShadow: lifted ? tokens.shadowLift : tokens.shadowSoft,
      ),
      padding: EdgeInsets.fromLTRB(side, side, side, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          photo,
          SizedBox(
            height: bottom,
            child: caption == null
                ? null
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.handNote.copyWith(
                        color: tokens.colors.inkMuted,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
