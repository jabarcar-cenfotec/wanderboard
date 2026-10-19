import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/rating_circles.dart';
import '../../../shared/widgets/atoms/tag_chip.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../domain/place.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/photo_gallery.dart';

class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({
    super.key,
    required this.place,
    required this.boardTitles,
    required this.onBack,
    required this.onEdit,
  });

  final Place place;
  final List<String> boardTitles;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PhotoGallery(place: place, onBack: onBack, onEdit: onEdit),
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
                        place.location,
                        style: tokens.text.caption.copyWith(color: c.inkMuted),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.sm),
                Text(
                  'visited ${formatVisitDate(place.visitedOn)}',
                  style: tokens.handNote.copyWith(color: c.slate),
                ),
                SizedBox(height: s.lg),
                RatingCircles(rating: place.rating),
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
                    'Pinned to ${boardTitles.join(' · ')}',
                    style: tokens.text.caption.copyWith(color: c.inkMuted),
                  ),
                ],
                SizedBox(height: s.xl),
                MapPlaceholder(label: place.city),
                SizedBox(height: s.xl),
                PrimaryButton(
                  label: 'Edit review',
                  icon: WanderIcons.edit,
                  onPressed: onEdit,
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
                child: Text('My private note', style: tokens.text.titleM),
              ),
              Icon(WanderIcons.lock, size: s.lg + s.xs, color: c.inkMuted),
              SizedBox(width: s.xs),
              Text(
                'Only you',
                style: tokens.text.caption.copyWith(color: c.inkMuted),
              ),
            ],
          ),
          SizedBox(height: s.sm),
          Text(
            note.isEmpty ? 'No words yet — just the feeling.' : note,
            style: tokens.text.body,
          ),
        ],
      ),
    );
  }
}
