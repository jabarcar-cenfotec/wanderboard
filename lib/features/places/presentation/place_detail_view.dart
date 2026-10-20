import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/star_rating.dart';
import '../../../shared/widgets/atoms/tag_chip.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../domain/place.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/photo_gallery.dart';
import 'widgets/status_badge.dart';

class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({
    super.key,
    required this.place,
    required this.boardTitles,
    required this.onBack,
    required this.onEdit,
    required this.onRegisterVisit,
    required this.onOpenGoogleMaps,
    required this.onOpenWaze,
  });

  final Place place;
  final List<String> boardTitles;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  /// Opens the editor with the status set to "Ya visité" (CU-02).
  final VoidCallback onRegisterVisit;
  final VoidCallback onOpenGoogleMaps;
  final VoidCallback onOpenWaze;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PhotoGallery(place: place, onBack: onBack),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              s.screen,
              s.xl,
              s.screen,
              s.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList.list(
              children: [
                Text(place.name, style: tokens.text.displayM),
                SizedBox(height: s.sm),
                Row(
                  children: [
                    Icon(WanderIcons.pin, size: s.lg + s.xs, color: c.inkMuted),
                    SizedBox(width: s.xs),
                    Expanded(
                      child: Text(
                        place.subtitle,
                        style: tokens.text.caption.copyWith(color: c.inkMuted),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.md),
                Wrap(
                  spacing: s.sm,
                  runSpacing: s.xs,
                  children: [
                    StatusBadge(status: place.status),
                    if (place.isSample) const SampleLabel(),
                  ],
                ),
                if (place.visitedOn case final visitedOn?) ...[
                  SizedBox(height: s.sm),
                  Text(
                    'Visitado el ${formatVisitDate(visitedOn)}',
                    style: tokens.handNote.copyWith(color: c.slate),
                  ),
                ],
                // H8, H9: the main action sits on top, without scrolling.
                SizedBox(height: s.lg),
                if (place.status.isPending) ...[
                  PrimaryButton(
                    label: 'Registrar visita',
                    icon: WanderIcons.check,
                    onPressed: onRegisterVisit,
                  ),
                  SizedBox(height: s.sm),
                  SecondaryButton(
                    label: 'Editar registro',
                    icon: WanderIcons.edit,
                    onPressed: onEdit,
                  ),
                ] else
                  SecondaryButton(
                    label: 'Editar registro',
                    icon: WanderIcons.edit,
                    onPressed: onEdit,
                  ),
                if (place.rating > 0) ...[
                  SizedBox(height: s.lg),
                  StarRating(rating: place.rating),
                ],
                SizedBox(height: s.xl),
                _PrivateNote(note: place.note),
                if (place.tags.isNotEmpty) ...[
                  SizedBox(height: s.xl),
                  Wrap(
                    spacing: s.sm,
                    runSpacing: s.sm,
                    children: [
                      for (final tag in place.tags) TagChip(label: tag),
                    ],
                  ),
                ],
                if (boardTitles.isNotEmpty) ...[
                  SizedBox(height: s.lg),
                  Text(
                    'En las colecciones: ${boardTitles.join(' · ')}',
                    style: tokens.text.caption.copyWith(color: c.inkMuted),
                  ),
                ],
                SizedBox(height: s.xl),
                MapPlaceholder(label: place.city),
                if (place.address.isNotEmpty) ...[
                  SizedBox(height: s.sm),
                  Text(
                    place.address,
                    style: tokens.text.caption.copyWith(color: c.inkMuted),
                  ),
                ],
                // H5: open the place in a real maps app.
                SizedBox(height: s.md),
                SecondaryButton(
                  label: 'Abrir en Google Maps',
                  icon: WanderIcons.pin,
                  onPressed: onOpenGoogleMaps,
                ),
                SizedBox(height: s.sm),
                SecondaryButton(
                  label: 'Abrir en Waze',
                  icon: WanderIcons.pin,
                  onPressed: onOpenWaze,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivateNote extends StatelessWidget {
  const _PrivateNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    return Container(
      padding: EdgeInsets.all(s.lg),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(tokens.radii.md),
        boxShadow: tokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Mi nota privada', style: tokens.text.titleM),
              ),
              Icon(WanderIcons.lock, size: s.lg + s.xs, color: c.inkMuted),
              SizedBox(width: s.xs),
              Text(
                'Solo tú',
                style: tokens.text.caption.copyWith(color: c.inkMuted),
              ),
            ],
          ),
          SizedBox(height: s.sm),
          Text(
            note.isEmpty ? 'Todavía no hay nota.' : note,
            style: tokens.text.body,
          ),
        ],
      ),
    );
  }
}
