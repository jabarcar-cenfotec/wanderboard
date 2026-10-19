import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import 'pressable.dart';

enum _ButtonVariant { primary, secondary, ghost }

/// Primary CTA: `apricot` fill with `ink` text (never white, DESIGN.md §2).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) => _WanderButton(
    variant: _ButtonVariant.primary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    expanded: expanded,
  );
}

/// Secondary: `slate` fill with `card` text.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) => _WanderButton(
    variant: _ButtonVariant.secondary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    expanded: expanded,
  );
}

/// Ghost: no fill, 1.5 `line` border, `ink` text.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) => _WanderButton(
    variant: _ButtonVariant.ghost,
    label: label,
    onPressed: onPressed,
    icon: icon,
    expanded: expanded,
  );
}

class _WanderButton extends StatelessWidget {
  const _WanderButton({
    required this.variant,
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.expanded,
  });

  final _ButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final scheme = Theme.of(context).colorScheme;

    final (Color? fill, Color foreground, Border? border) = switch (variant) {
      _ButtonVariant.primary => (scheme.primary, scheme.onPrimary, null),
      _ButtonVariant.secondary => (scheme.secondary, scheme.onSecondary, null),
      _ButtonVariant.ghost => (
        null,
        tokens.colors.ink,
        Border.all(color: tokens.colors.line, width: tokens.sizes.ghostBorder),
      ),
    };
    final disabled = onPressed == null;
    final textColor = disabled ? tokens.colors.inkFaint : foreground;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Pressable(
        onTap: onPressed,
        builder: (context, pressed) => AnimatedContainer(
          duration: tokens.motion.fast,
          curve: tokens.motion.curve,
          height: tokens.sizes.buttonHeight,
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xl),
          decoration: BoxDecoration(
            color: fill,
            border: border,
            borderRadius: BorderRadius.circular(tokens.radii.md),
            boxShadow: fill == null
                ? null
                : (pressed ? tokens.shadowLift : tokens.shadowSoft),
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: tokens.sizes.icon),
                SizedBox(width: tokens.spacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.text.bodyStrong.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
