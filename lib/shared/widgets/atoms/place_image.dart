import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../icons/wander_icons.dart';

/// Photo loaded from picsum by a stable seed.
///
/// While loading or when offline it falls back to the `mistLake` gradient
/// with a soft icon, so the layout never breaks.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.seed,
    this.aspectRatio,
    this.borderRadius = BorderRadius.zero,
    this.pixelWidth = 600,
  });

  final String seed;

  /// Width / height. When null the image fills its parent constraints.
  final double? aspectRatio;
  final BorderRadius borderRadius;
  final int pixelWidth;

  String get url {
    final ratio = aspectRatio ?? 1;
    final pixelHeight = (pixelWidth / ratio).round();
    return 'https://picsum.photos/seed/$seed/$pixelWidth/$pixelHeight';
  }

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _MistPlaceholder(showIcon: false);
        },
        errorBuilder: (context, error, stack) =>
            const _MistPlaceholder(showIcon: true),
      ),
    );

    final ratio = aspectRatio;
    return ratio == null
        ? image
        : AspectRatio(aspectRatio: ratio, child: image);
  }
}

class _MistPlaceholder extends StatelessWidget {
  const _MistPlaceholder({required this.showIcon});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.gradients.mistLake),
      child: showIcon
          ? Center(
              child: Icon(
                WanderIcons.photo,
                color: tokens.colors.card.withValues(alpha: 0.8),
                size: tokens.sizes.icon,
              ),
            )
          : const SizedBox.expand(),
    );
  }
}
