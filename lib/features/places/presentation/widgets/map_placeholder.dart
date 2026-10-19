import 'package:flutter/material.dart';

import '../../../../core/theme/wander_tokens.dart';
import '../../../../shared/icons/wander_icons.dart';
import '../../../../shared/widgets/molecules/frosted_card.dart';

/// Static map stand-in: `mistLake` gradient with soft mist "roads" and an
/// apricot pin. No real map integration in the mockup.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final c = tokens.colors;
    final pin = tokens.sizes.ratingCircle + tokens.spacing.xs;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radii.md),
      child: SizedBox(
        height: tokens.sizes.mapHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.gradients.mistLake),
            ),
            CustomPaint(
              painter: _RoadsPainter(
                road: c.mist.withValues(alpha: 0.55),
                water: c.card.withValues(alpha: 0.18),
              ),
            ),
            Center(
              child: Container(
                width: pin,
                height: pin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.apricot,
                  border: Border.all(
                    color: c.card,
                    width: tokens.sizes.focusBorder,
                  ),
                  boxShadow: tokens.shadowLift,
                ),
                child: Icon(
                  WanderIcons.pin,
                  color: c.ink,
                  size: tokens.spacing.xl - tokens.spacing.xs,
                ),
              ),
            ),
            Positioned(
              left: tokens.spacing.md,
              bottom: tokens.spacing.md,
              child: FrostedCard(
                borderRadius: BorderRadius.circular(tokens.radii.sm),
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.xs + tokens.spacing.xs / 2,
                ),
                child: Text(label, style: tokens.text.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadsPainter extends CustomPainter {
  const _RoadsPainter({required this.road, required this.water});

  final Color road;
  final Color water;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final waterPath = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.3, h * 0.6, w * 0.55, h * 0.8)
      ..quadraticBezierTo(w * 0.8, h * 0.95, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, Paint()..color = water);

    final paint = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas
      ..drawPath(
        Path()
          ..moveTo(-10, h * 0.25)
          ..quadraticBezierTo(w * 0.4, h * 0.45, w + 10, h * 0.2),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(w * 0.3, -10)
          ..quadraticBezierTo(w * 0.45, h * 0.5, w * 0.35, h + 10),
        paint,
      )
      ..drawLine(
        Offset(w * 0.62, 0),
        Offset(w * 0.75, h),
        paint..strokeWidth = 1.5,
      )
      ..drawLine(Offset(0, h * 0.5), Offset(w, h * 0.58), paint);
  }

  @override
  bool shouldRepaint(_RoadsPainter oldDelegate) =>
      road != oldDelegate.road || water != oldDelegate.water;
}
