import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/pressable.dart';
import '../../../../shared/widgets/atoms/washi_tape.dart';
import '../board_summary.dart';

/// Board card: collage of 1 large + 2 small photos, name in `titleL`,
/// count in `caption`. Featured boards get the single washi-tape accent.
class BoardCollageCard extends StatelessWidget {
  const BoardCollageCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final BoardSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Open board ${summary.board.title}',
      builder: (context, pressed) {
        Widget collage = AnimatedContainer(
          duration: tokens.motion.fast,
          curve: tokens.motion.curve,
          height: tokens.sizes.coverHeroHeight * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radii.md),
            boxShadow: pressed ? tokens.shadowLift : tokens.shadowSoft,
          ),
          child: _Collage(seeds: summary.photoSeeds),
        );
        if (summary.board.featured) {
          collage = Taped(leanRight: true, child: collage);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            collage,
            SizedBox(height: s.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(summary.board.title, style: tokens.text.titleL),
                ),
                SizedBox(width: s.sm),
                Text(
                  summary.countLabel,
                  style: tokens.text.caption.copyWith(
                    color: tokens.colors.inkMuted,
                  ),
                ),
              ],
            ),
            Text(
              summary.board.note,
              style: tokens.handNote.copyWith(color: tokens.colors.inkMuted),
            ),
          ],
        );
      },
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.seeds});

  final List<String> seeds;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final gap = tokens.spacing.xs;
    final radius = Radius.circular(tokens.radii.md);

    String seedAt(int i) =>
        seeds.isEmpty ? 'wb-empty' : seeds[i % seeds.length];

    if (seeds.length < 3) {
      return PlaceImage(
        seed: seedAt(0),
        aspectRatio: null,
        borderRadius: BorderRadius.all(radius),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PlaceImage(
            seed: seedAt(0),
            borderRadius: BorderRadius.horizontal(left: radius),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: PlaceImage(
                  seed: seedAt(1),
                  pixelWidth: 300,
                  borderRadius: BorderRadius.only(topRight: radius),
                ),
              ),
              SizedBox(height: gap),
              Expanded(
                child: PlaceImage(
                  seed: seedAt(2),
                  pixelWidth: 300,
                  borderRadius: BorderRadius.only(bottomRight: radius),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
