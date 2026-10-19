import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Press feedback from DESIGN.md §7: scale 0.97 while pressed.
///
/// [builder] receives the pressed state so children can swap
/// `shadowSoft` for `shadowLift`.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.semanticLabel,
  });

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool pressed) builder;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.wander.motion;
    final enabled = widget.onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? motion.pressScale : 1,
          duration: motion.fast,
          curve: motion.curve,
          child: widget.builder(context, _pressed),
        ),
      ),
    );
  }
}
