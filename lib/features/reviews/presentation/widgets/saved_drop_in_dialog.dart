import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../places/presentation/widgets/place_polaroid_card.dart';
import '../../../../shared/icons/wander_icons.dart';
import '../../../../shared/widgets/atoms/drop_in.dart';
import '../../../../shared/widgets/atoms/place_image.dart';
import '../../../../shared/widgets/atoms/tilted_item.dart';
import '../../../../shared/widgets/molecules/polaroid_frame.dart';
import '../../../places/domain/place.dart';

/// Shows the saved polaroid dropping in, then closes itself.
Future<void> showSavedDropIn(BuildContext context, Place place) {
  final tokens = context.wander;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Guardado',
    barrierColor: tokens.colors.ink.withValues(alpha: 0.25),
    transitionDuration: tokens.motion.base,
    pageBuilder: (context, _, _) => _SavedDropIn(place: place),
  );
}

class _SavedDropIn extends StatefulWidget {
  const _SavedDropIn({required this.place});

  final Place place;

  @override
  State<_SavedDropIn> createState() => _SavedDropInState();
}

class _SavedDropInState extends State<_SavedDropIn> {
  static const _visibleFor = Duration(milliseconds: 1300);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_visibleFor, () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final width = MediaQuery.sizeOf(context).width * 0.6;

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropIn(
              finalAngle: TiltedItem.radiansFor(context, widget.place.id),
              child: SizedBox(
                width: width,
                child: PolaroidFrame(
                  lifted: true,
                  caption: polaroidCaption(widget.place),
                  photo: PlaceImage(
                    seed: widget.place.cover.seed,
                    aspectRatio: widget.place.cover.aspectRatio,
                  ),
                ),
              ),
            ),
            SizedBox(height: s.xl),
            Container(
              padding: EdgeInsets.symmetric(horizontal: s.lg, vertical: s.sm),
              decoration: BoxDecoration(
                color: tokens.colors.card,
                borderRadius: BorderRadius.circular(tokens.radii.pill),
                boxShadow: tokens.shadowSoft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(WanderIcons.check, color: tokens.colors.success),
                  SizedBox(width: s.sm),
                  Text('Guardado en tu diario', style: tokens.text.bodyStrong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
