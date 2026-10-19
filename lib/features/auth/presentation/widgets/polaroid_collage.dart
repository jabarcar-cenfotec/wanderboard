import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/tilted_item.dart';
import '../../../../shared/widgets/atoms/washi_tape.dart';
import '../../../../shared/widgets/molecules/polaroid_frame.dart';

/// Three overlapping polaroids for the onboarding hero.
/// Only the center one carries washi tape (one accent).
class PolaroidCollage extends StatelessWidget {
  const PolaroidCollage({super.key, required this.seeds});

  final List<String> seeds;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = width * 0.52;
        final height = cardWidth * 1.35;

        Widget polaroid(int index) {
          final seed = seeds.isEmpty
              ? 'wb-onboarding-$index'
              : seeds[index % seeds.length];
          return SizedBox(
            width: cardWidth,
            child: PolaroidFrame(
              photo: PlaceImage(seed: seed, aspectRatio: 0.9),
            ),
          );
        }

        return SizedBox(
          height: height + tokens.spacing.xl,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: tokens.spacing.xl,
                child: TiltedItem(id: 'collage-a', child: polaroid(1)),
              ),
              Positioned(
                right: 0,
                top: tokens.spacing.xxl,
                child: TiltedItem(id: 'collage-c', child: polaroid(2)),
              ),
              Positioned(
                left: (width - cardWidth) / 2,
                top: 0,
                child: TiltedItem(
                  id: 'collage-b',
                  child: Taped(child: polaroid(0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
