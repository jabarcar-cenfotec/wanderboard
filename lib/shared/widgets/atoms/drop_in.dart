import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// "New item saved" motion: translateY −12 → 0, rotate to the final tilt,
/// fade in (DESIGN.md §7).
class DropIn extends StatefulWidget {
  const DropIn({
    super.key,
    required this.child,
    this.finalAngle = 0,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// Final rotation in radians.
  final double finalAngle;
  final Duration delay;

  @override
  State<DropIn> createState() => _DropInState();
}

class _DropInState extends State<DropIn> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: context.wander.motion.slow,
    );
    _controller = controller;
    if (widget.delay == Duration.zero) {
      controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.wander.motion;
    final curved = CurvedAnimation(parent: _controller!, curve: motion.curve);
    final startAngle =
        widget.finalAngle + motion.radians(motion.dropSpinDegrees);

    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -motion.dropOffset * (1 - t)),
            child: Transform.rotate(
              angle: startAngle + (widget.finalAngle - startAngle) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
