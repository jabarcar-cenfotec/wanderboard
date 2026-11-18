import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/place_image.dart';
import '../../../shared/widgets/atoms/stat_circle.dart';
import '../domain/user_profile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.profile,
    required this.stats,
    required this.onSettingTap,
    required this.onPrivacyTap,
    required this.onSignOut,
  });

  final UserProfile profile;
  final DiaryStats stats;
  final ValueChanged<String> onSettingTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final avatar = tokens.sizes.avatar;
    final bottomInset =
        tokens.sizes.navAddButton +
        s.xxxl +
        MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.gradients.mistDawn),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(s.screen, s.xxl, s.screen, bottomInset),
          children: [
            Center(
              child: Container(
                width: avatar,
                height: avatar,
                padding: EdgeInsets.all(s.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.polaroid,
                  boxShadow: tokens.shadowSoft,
                ),
                child: PlaceImage(
                  seed: profile.avatarSeed,
                  pixelWidth: 200,
                  borderRadius: BorderRadius.circular(tokens.radii.pill),
                ),
              ),
            ),
            SizedBox(height: s.lg),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: tokens.text.displayM,
            ),
            Text(
              profile.motto,
              textAlign: TextAlign.center,
              style: tokens.handNote.copyWith(color: c.inkMuted),
            ),
            SizedBox(height: s.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCircle(value: stats.places, label: 'lugares'),
                StatCircle(value: stats.boards, label: 'colecciones'),
                StatCircle(value: stats.cities, label: 'ciudades'),
              ],
            ),
            SizedBox(height: s.xxl),
            _SettingsCard(
              children: [
                _SettingTile(
                  icon: WanderIcons.lock,
                  title: 'Privacidad y cifrado',
                  subtitle: 'Tu diario se cifra en este dispositivo',
                  onTap: onPrivacyTap,
                ),
                _SettingTile(
                  icon: WanderIcons.bell,
                  title: 'Recordatorios',
                  subtitle: 'Avisarme para escribir después de un viaje',
                  onTap: () => onSettingTap('Recordatorios'),
                ),
                _SettingTile(
                  icon: WanderIcons.appearance,
                  title: 'Apariencia',
                  subtitle: 'Papel (claro)',
                  onTap: () => onSettingTap('Apariencia'),
                ),
                _SettingTile(
                  icon: WanderIcons.export,
                  title: 'Exportar mi diario',
                  subtitle: 'Álbum en PDF o fotos',
                  onTap: () => onSettingTap('Exportar'),
                ),
              ],
            ),
            SizedBox(height: s.lg),
            _SettingsCard(
              children: [
                _SettingTile(
                  icon: WanderIcons.signOut,
                  title: 'Cerrar sesión',
                  subtitle: profile.email.isEmpty
                      ? profile.name
                      : profile.email,
                  onTap: onSignOut,
                  showChevron: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final radius = BorderRadius.circular(tokens.radii.md);
    // Shadow on the outside; ListTiles need a Material surface for ink.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tokens.shadowSoft,
      ),
      child: Material(
        color: tokens.colors.card,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  indent: tokens.spacing.lg,
                  endIndent: tokens.spacing.lg,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title, style: tokens.text.bodyStrong),
      subtitle: Text(subtitle),
      trailing: showChevron
          ? Icon(WanderIcons.chevron, color: tokens.colors.inkFaint)
          : null,
    );
  }
}
