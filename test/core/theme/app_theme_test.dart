import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/core/theme/wander_palette.dart';
import 'package:wanderboard/core/theme/wander_tokens.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTheme', () {
    test('exposes WanderTokens as a ThemeExtension', () {
      final tokens = testTheme().extension<WanderTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.colors.tape, WanderPalette.tape);
      expect(tokens.radii.polaroid, 6);
      expect(tokens.spacing.lg, 16);
      expect(tokens.shadowSoft, isNotEmpty);
    });

    test('maps the color scheme from DESIGN.md', () {
      final scheme = testTheme().colorScheme;

      expect(scheme.primary, WanderPalette.apricot);
      expect(scheme.onPrimary, WanderPalette.ink);
      expect(scheme.secondary, WanderPalette.slate);
      expect(scheme.onSecondary, WanderPalette.card);
      expect(scheme.surface, WanderPalette.card);
      expect(testTheme().scaffoldBackgroundColor, WanderPalette.paper);
    });
  });
}
