import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/icons/wander_icons.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/molecules/frosted_card.dart';
import '../../domain/place.dart';
import 'place_polaroid_card.dart';

/// Swipeable photo gallery. The first photo is the [Hero] destination
/// from the grid. No tilt here (detail view).
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.place,
    required this.onBack,
    required this.onEdit,
  });

  final Place place;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final photos = widget.place.photos;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(tokens.radii.lg),
      ),
      child: SizedBox(
        height: tokens.sizes.galleryHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: photos.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final image = PlaceImage(
                  seed: photos[index].seed,
                  pixelWidth: 900,
                );
                if (index != 0) return image;
                return Hero(
                  tag: placePhotoHeroTag(widget.place.id),
                  child: image,
                );
              },
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: tokens.gradients.photoScrim,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(s.screen),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FrostedIconButton(
                      icon: WanderIcons.back,
                      tooltip: 'Back',
                      onPressed: widget.onBack,
                    ),
                    FrostedIconButton(
                      icon: WanderIcons.edit,
                      tooltip: 'Edit review',
                      onPressed: widget.onEdit,
                    ),
                  ],
                ),
              ),
            ),
            if (photos.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: s.lg,
                child: _PageDots(count: photos.length, current: _page),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final dot = tokens.spacing.sm;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: tokens.motion.base,
            curve: tokens.motion.curve,
            margin: EdgeInsets.symmetric(horizontal: tokens.spacing.xs / 2),
            width: i == current ? dot * 3 : dot,
            height: dot,
            decoration: BoxDecoration(
              color: i == current
                  ? tokens.colors.card
                  : tokens.colors.card.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(tokens.radii.pill),
            ),
          ),
      ],
    );
  }
}
