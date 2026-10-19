import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../icons/wander_icons.dart';
import '../atoms/pressable.dart';

enum WanderTab { boards, profile }

/// Bottom navigation: `card` @ 90% + blur, Boards · Add · Profile.
/// The center "Add" is a 56 px `apricot` circle (DESIGN.md §6).
class WanderBottomNav extends StatelessWidget {
  const WanderBottomNav({
    super.key,
    required this.current,
    required this.onBoards,
    required this.onAdd,
    required this.onProfile,
  });

  final WanderTab current;
  final VoidCallback onBoards;
  final VoidCallback onAdd;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final blur = tokens.sizes.frostedBlur;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radii.lg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.colors.card.withValues(
              alpha: tokens.sizes.navOpacity,
            ),
            border: Border(top: BorderSide(color: tokens.colors.line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.xl,
                vertical: tokens.spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: WanderIcons.boards,
                    label: 'Mis lugares',
                    active: current == WanderTab.boards,
                    onTap: onBoards,
                  ),
                  _AddButton(onTap: onAdd),
                  _NavItem(
                    icon: WanderIcons.profile,
                    label: 'Perfil',
                    active: current == WanderTab.profile,
                    onTap: onProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final color = active ? tokens.colors.ink : tokens.colors.inkMuted;

    return Semantics(
      selected: active,
      child: Pressable(
        onTap: onTap,
        builder: (context, _) => SizedBox(
          width: tokens.sizes.statCircle + tokens.spacing.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? tokens.colors.apricot : color),
              SizedBox(height: tokens.spacing.xs),
              Text(label, style: tokens.text.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final scheme = Theme.of(context).colorScheme;
    final size = tokens.sizes.navAddButton;

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Agregar lugar',
      builder: (context, pressed) => AnimatedContainer(
        duration: tokens.motion.fast,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary,
          boxShadow: pressed ? tokens.shadowLift : tokens.shadowSoft,
        ),
        child: Icon(WanderIcons.add, color: scheme.onPrimary),
      ),
    );
  }
}
