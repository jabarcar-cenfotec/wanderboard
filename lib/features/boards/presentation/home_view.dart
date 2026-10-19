import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/widgets/atoms/overline_label.dart';
import 'board_summary.dart';
import 'widgets/board_collage_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.greeting,
    required this.placeCount,
    required this.boards,
    required this.onOpenBoard,
  });

  final String greeting;
  final int placeCount;
  final List<BoardSummary> boards;
  final ValueChanged<String> onOpenBoard;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final bottomInset =
        tokens.sizes.navAddButton +
        s.xxxl +
        MediaQuery.paddingOf(context).bottom;

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
                    OverlineLabel('Your diary · $placeCount places'),
                    SizedBox(height: s.sm),
                    Text(greeting, style: tokens.text.displayM),
                    SizedBox(height: s.xl),
                    Text('My boards', style: tokens.text.titleL),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(s.screen, 0, s.screen, bottomInset),
              sliver: SliverList.separated(
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
            ),
          ],
        ),
      ),
    );
  }
}
