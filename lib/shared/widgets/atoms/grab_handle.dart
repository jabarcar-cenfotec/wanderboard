import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';

/// 40×4 bottom-sheet grab handle in `line`.
class GrabHandle extends StatelessWidget {
  const GrabHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final size = tokens.sizes.grabHandle;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: tokens.colors.line,
        borderRadius: BorderRadius.circular(tokens.radii.pill),
      ),
    );
  }
}
