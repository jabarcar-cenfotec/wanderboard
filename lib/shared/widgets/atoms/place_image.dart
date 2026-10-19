import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../icons/wander_icons.dart';

/// Photo loaded from picsum: `id:<n>` picks a curated image, any other seed
/// a stable random one; an empty seed renders a placeholder.
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
    final source = seed.startsWith('id:')
        ? 'id/${seed.substring(3)}'
        : 'seed/$seed';
    return 'https://picsum.photos/$source/$pixelWidth/$pixelHeight';
  }

  @override
  Widget build(BuildContext context) {
    if (seed.isEmpty) {
      final placeholder = ClipRRect(
        borderRadius: borderRadius,
        child: const _MistPlaceholder(showIcon: true, icon: WanderIcons.pin),
      );
      final ratio = aspectRatio;
      return ratio == null
          ? placeholder
          : AspectRatio(aspectRatio: ratio, child: placeholder);
    }

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
  const _MistPlaceholder({
    required this.showIcon,
    this.icon = WanderIcons.photo,
  });

  final bool showIcon;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.gradients.mistLake),
      child: showIcon
          ? Center(
              child: Icon(
                icon,
                color: tokens.colors.card.withValues(alpha: 0.8),
                size: tokens.sizes.icon,
              ),
            )
          : const SizedBox.expand(),
    );
  }
}
