import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/place_image.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../../../shared/widgets/molecules/frosted_card.dart';
import '../../places/domain/place.dart';
import '../../places/presentation/widgets/place_polaroid_card.dart';
import 'board_summary.dart';

class BoardDetailView extends StatelessWidget {
  const BoardDetailView({
    super.key,
    required this.summary,
    required this.places,
    required this.onBack,
    required this.onShare,
    required this.onOpenPlace,
    required this.onAddPlace,
    this.dropInId,
  });

  final BoardSummary summary;
  final List<Place> places;
  final String? dropInId;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final ValueChanged<String> onOpenPlace;
  final VoidCallback onAddPlace;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _CoverHero(
              summary: summary,
              onBack: onBack,
              onShare: onShare,
            ),
          ),
          if (places.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Aún no hay lugares en esta colección',
                  style: tokens.handNote.copyWith(
                    color: tokens.colors.inkMuted,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(s.screen, s.xl, s.screen, s.xl),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: s.xl,
                crossAxisSpacing: s.grid,
                childCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return PlacePolaroidCard(
                    key: ValueKey(place.id),
                    place: place,
                    dropIn: place.id == dropInId,
                    onTap: () => onOpenPlace(place.id),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              s.screen,
              0,
              s.screen,
              s.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverToBoxAdapter(
              child: GhostButton(
                label: 'Agregar lugar',
                icon: WanderIcons.add,
                onPressed: onAddPlace,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverHero extends StatelessWidget {
  const _CoverHero({
    required this.summary,
    required this.onBack,
    required this.onShare,
  });

  final BoardSummary summary;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final onPhoto = tokens.colors.card;
    final seed = summary.photoSeeds.isEmpty
        ? 'wb-empty'
        : summary.photoSeeds.first;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(tokens.radii.lg),
      ),
      child: SizedBox(
        height: tokens.sizes.coverHeroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PlaceImage(seed: seed, pixelWidth: 900),
            DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.gradients.photoScrim),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(s.screen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FrostedIconButton(
                          icon: WanderIcons.back,
                          tooltip: 'Volver',
                          onPressed: onBack,
                        ),
                        FrostedIconButton(
                          icon: WanderIcons.share,
                          tooltip: 'Compartir colección',
                          onPressed: onShare,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      summary.board.title,
                      style: tokens.text.displayM.copyWith(color: onPhoto),
                    ),
                    SizedBox(height: s.xs),
                    Text(
                      '${summary.countLabel} · ${summary.board.note}',
                      style: tokens.text.caption.copyWith(color: onPhoto),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
