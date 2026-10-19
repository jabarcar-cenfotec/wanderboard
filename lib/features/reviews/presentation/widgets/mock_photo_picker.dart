import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/icons/wander_icons.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/pressable.dart';
import '../../../places/domain/place.dart';

/// Fake camera roll: a camera tile followed by selectable photos.
class MockPhotoPicker extends StatelessWidget {
  const MockPhotoPicker({
    super.key,
    required this.library,
    required this.selected,
    required this.onToggle,
    required this.onCamera,
  });

  final List<PlacePhoto> library;
  final List<PlacePhoto> selected;
  final ValueChanged<PlacePhoto> onToggle;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final gap = tokens.spacing.sm;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
      ),
      itemCount: library.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _CameraTile(onTap: onCamera);
        final photo = library[index - 1];
        final order = selected.indexWhere((p) => p.seed == photo.seed);
        return _PhotoTile(
          photo: photo,
          order: order < 0 ? null : order + 1,
          onTap: () => onToggle(photo),
        );
      },
    );
  }
}

class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Take a photo',
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radii.sm),
          border: Border.all(
            color: tokens.colors.line,
            width: tokens.sizes.ghostBorder,
          ),
          color: tokens.colors.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(WanderIcons.camera, color: tokens.colors.inkMuted),
            SizedBox(height: tokens.spacing.xs),
            Text(
              'Camera',
              style: tokens.text.caption.copyWith(
                color: tokens.colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.order,
    required this.onTap,
  });

  final PlacePhoto photo;
  final int? order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final c = tokens.colors;
    final isSelected = order != null;
    final badge = tokens.spacing.xl;

    return Pressable(
      onTap: onTap,
      semanticLabel: isSelected ? 'Deselect photo' : 'Select photo',
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          PlaceImage(
            seed: photo.seed,
            pixelWidth: 240,
            borderRadius: BorderRadius.circular(tokens.radii.sm),
          ),
          AnimatedContainer(
            duration: tokens.motion.fast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radii.sm),
              border: Border.all(
                color: isSelected ? c.apricot : c.card.withValues(alpha: 0),
                width: tokens.sizes.focusBorder + 1,
              ),
            ),
          ),
          Positioned(
            top: tokens.spacing.sm,
            right: tokens.spacing.sm,
            child: AnimatedContainer(
              duration: tokens.motion.fast,
              width: badge,
              height: badge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? c.apricot : c.card.withValues(alpha: 0.6),
                border: Border.all(
                  color: c.card,
                  width: tokens.sizes.ghostBorder,
                ),
              ),
              child: isSelected
                  ? Text(
                      '$order',
                      style: tokens.text.caption.copyWith(color: c.ink),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
