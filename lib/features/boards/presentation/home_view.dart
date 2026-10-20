import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/overline_label.dart';
import '../../../shared/widgets/atoms/tag_chip.dart';
import '../../places/domain/place.dart';
import '../../places/presentation/place_list.dart';
import '../../places/presentation/widgets/place_row_card.dart';
import 'board_summary.dart';
import 'widgets/board_collage_card.dart';

/// "Mis lugares": pending places, visit history and collections (CU-03).
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.greeting,
    required this.placeCount,
    required this.list,
    required this.query,
    required this.type,
    required this.places,
    required this.boards,
    required this.onSelectList,
    required this.onQueryChanged,
    required this.onTypeChanged,
    required this.onOpenPlace,
    required this.onOpenBoard,
  });

  final String greeting;
  final int placeCount;
  final PlaceList list;

  /// Search text; when not empty, [places] holds the search results.
  final String query;

  /// Type filter of the pending and history lists; null shows every type.
  final PlaceType? type;

  /// Places of [list] or the search results; ignored for collections.
  final List<Place> places;
  final List<BoardSummary> boards;
  final ValueChanged<PlaceList> onSelectList;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<PlaceType?> onTypeChanged;
  final ValueChanged<String> onOpenPlace;
  final ValueChanged<String> onOpenBoard;

  static const _emptyMessages = {
    PlaceList.pending: 'No tienes lugares pendientes.',
    PlaceList.history: 'Todavía no has registrado visitas.',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final bottomInset =
        tokens.sizes.navAddButton +
        s.xxxl +
        MediaQuery.paddingOf(context).bottom;

    final searching = query.trim().isNotEmpty;
    final emptyMessage = searching
        ? 'No hay lugares que coincidan con “${query.trim()}”.'
        : _emptyMessages[list];

    final Widget content = switch (list) {
      PlaceList.collections when !searching => SliverList.separated(
        itemCount: boards.length,
        separatorBuilder: (context, _) => SizedBox(height: s.xl),
        itemBuilder: (context, index) {
          final summary = boards[index];
          return BoardCollageCard(
            summary: summary,
            onTap: () => onOpenBoard(summary.board.id),
          );
        },
      ),
      _ when places.isEmpty => SliverToBoxAdapter(
        child: Text(
          emptyMessage!,
          style: tokens.text.body.copyWith(color: c.inkMuted),
        ),
      ),
      _ => SliverList.separated(
        itemCount: places.length,
        separatorBuilder: (context, _) => SizedBox(height: s.md),
        itemBuilder: (context, index) {
          final place = places[index];
          return PlaceRowCard(place: place, onTap: () => onOpenPlace(place.id));
        },
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.gradients.mistDawn),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(s.screen, s.xl, s.screen, s.xl),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OverlineLabel('Tu diario · $placeCount lugares'),
                    SizedBox(height: s.sm),
                    Text(greeting, style: tokens.text.displayM),
                    SizedBox(height: s.xl),
                    Text('Mis lugares', style: tokens.text.titleL),
                    SizedBox(height: s.md),
                    TextField(
                      onChanged: onQueryChanged,
                      textInputAction: TextInputAction.search,
                      style: tokens.text.body,
                      decoration: const InputDecoration(
                        hintText: 'Buscar en mis lugares',
                        prefixIcon: Icon(WanderIcons.search),
                      ),
                    ),
                    SizedBox(height: s.md),
                    Wrap(
                      spacing: s.sm,
                      runSpacing: s.sm,
                      children: [
                        for (final option in PlaceList.values)
                          TagChip(
                            label: option.label,
                            selected: option == list,
                            onTap: () => onSelectList(option),
                          ),
                      ],
                    ),
                    if (list != PlaceList.collections) ...[
                      SizedBox(height: s.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final option in [null, ...PlaceType.values])
                              Padding(
                                padding: EdgeInsets.only(right: s.sm),
                                child: TagChip(
                                  label: option?.label ?? 'Todos',
                                  selected: option == type,
                                  onTap: () => onTypeChanged(option),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(s.screen, 0, s.screen, bottomInset),
              sliver: content,
            ),
          ],
        ),
      ),
    );
  }
}
