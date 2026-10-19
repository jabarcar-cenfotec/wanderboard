import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// Uppercase `overline` label in `inkMuted`.
class OverlineLabel extends StatelessWidget {
  const OverlineLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    return Text(
      text.toUpperCase(),
      style: tokens.text.overline.copyWith(color: tokens.colors.inkMuted),
    );
  }
}
