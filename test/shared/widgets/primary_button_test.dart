import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/core/theme/wander_palette.dart';
import 'package:wanderboard/shared/widgets/atoms/wander_buttons.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('primary button text uses ink on apricot, never white', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(PrimaryButton(label: 'Save to diary', onPressed: () {})),
    );

    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Save to diary'),
    );

    expect(paragraph.text.style?.color, WanderPalette.ink);
  });

  testWidgets('primary button triggers its callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(PrimaryButton(label: 'Go', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Go'));

    expect(taps, 1);
  });
}
