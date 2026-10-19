import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// `card` @ 80% + backdrop blur 16. Use over photos/gradients only.
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final radius = borderRadius ?? BorderRadius.circular(tokens.radii.md);
    final blur = tokens.sizes.frostedBlur;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(tokens.spacing.lg),
          decoration: BoxDecoration(
            color: tokens.colors.card.withValues(
              alpha: tokens.sizes.frostedOpacity,
            ),
            borderRadius: radius,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Circular frosted icon button for actions that sit on top of photos.
class FrostedIconButton extends StatelessWidget {
  const FrostedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final size = tokens.sizes.buttonHeight - tokens.spacing.sm;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onPressed,
          child: FrostedCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(tokens.radii.pill),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                color: tokens.colors.ink,
                size: tokens.sizes.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
