import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/grab_handle.dart';
import '../../../shared/widgets/atoms/place_image.dart';
import '../../../shared/widgets/atoms/pressable.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../../boards/presentation/board_summary.dart';

/// Opens the (fake) share sheet for a board.
Future<void> showShareBoardSheet(BuildContext context, BoardSummary summary) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => ShareBoardSheet(
      summary: summary,
      onAction: (message) {
        Navigator.of(sheetContext).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}

class ShareBoardSheet extends StatefulWidget {
  const ShareBoardSheet({
    super.key,
    required this.summary,
    required this.onAction,
  });

  final BoardSummary summary;

  /// Called with a confirmation message after a (mock) share action.
  final ValueChanged<String> onAction;

  @override
  State<ShareBoardSheet> createState() => _ShareBoardSheetState();
}

class _ShareBoardSheetState extends State<ShareBoardSheet> {
  bool _includeNotes = false;

  String get _link => 'wanderboard.app/b/${widget.summary.board.id}';

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(s.xl, s.md, s.xl, s.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: GrabHandle()),
            SizedBox(height: s.xl),
            Text('Share board', style: tokens.text.titleL),
            SizedBox(height: s.xs),
            Text(
              'People with the link can see photos and places. '
              'Your notes stay private unless you include them.',
              style: tokens.text.caption.copyWith(color: c.inkMuted),
            ),
            SizedBox(height: s.xl),
            _LinkPreviewCard(summary: widget.summary, link: _link),
            SizedBox(height: s.lg),
            Row(
              children: [
                Icon(WanderIcons.lock, color: c.inkMuted),
                SizedBox(width: s.md),
                Expanded(
                  child: Text(
                    'Include my private notes',
                    style: tokens.text.body,
                  ),
                ),
                Switch(
                  value: _includeNotes,
                  onChanged: (value) => setState(() => _includeNotes = value),
                ),
              ],
            ),
            SizedBox(height: s.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShareOption(
                  icon: WanderIcons.copy,
                  label: 'Copy link',
                  onTap: () => widget.onAction('Link copied'),
                ),
                _ShareOption(
                  icon: WanderIcons.message,
                  label: 'Message',
                  onTap: () => widget.onAction('Sent as a message (mock)'),
                ),
                _ShareOption(
                  icon: WanderIcons.email,
                  label: 'Email',
                  onTap: () => widget.onAction('Email draft ready (mock)'),
                ),
                _ShareOption(
                  icon: WanderIcons.more,
                  label: 'More',
                  onTap: () => widget.onAction('More options (mock)'),
                ),
              ],
            ),
            SizedBox(height: s.xl),
            PrimaryButton(
              label: 'Copy link',
              icon: WanderIcons.link,
              onPressed: () => widget.onAction('Link copied'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({required this.summary, required this.link});

  final BoardSummary summary;
  final String link;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final seed = summary.photoSeeds.isEmpty
        ? 'wb-empty'
        : summary.photoSeeds.first;
    final thumb = tokens.sizes.statCircle + s.lg;

    return Container(
      padding: EdgeInsets.all(s.md),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(tokens.radii.md),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: thumb,
            height: thumb,
            child: PlaceImage(
              seed: seed,
              pixelWidth: 200,
              borderRadius: BorderRadius.circular(tokens.radii.sm),
            ),
          ),
          SizedBox(width: s.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.board.title, style: tokens.text.titleM),
                Text(
                  summary.countLabel,
                  style: tokens.text.caption.copyWith(color: c.inkMuted),
                ),
                SizedBox(height: s.xs),
                Row(
                  children: [
                    Icon(WanderIcons.link, size: s.lg, color: c.slate),
                    SizedBox(width: s.xs),
                    Flexible(
                      child: Text(
                        link,
                        overflow: TextOverflow.ellipsis,
                        style: tokens.text.caption.copyWith(color: c.slate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final size = tokens.sizes.statCircle;

    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, pressed) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: tokens.motion.fast,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.colors.card,
              border: Border.all(color: tokens.colors.line),
              boxShadow: pressed ? tokens.shadowLift : tokens.shadowSoft,
            ),
            child: Icon(icon, color: tokens.colors.ink),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(label, style: tokens.text.caption),
        ],
      ),
    );
  }
}
