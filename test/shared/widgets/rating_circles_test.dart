import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/shared/widgets/atoms/rating_circles.dart';

import '../../helpers/pump_app.dart';

void main() {
  int countCircles(WidgetTester tester, {required bool filled}) {
    return tester
        .widgetList<RatingCircle>(find.byType(RatingCircle))
        .where((circle) => circle.filled == filled)
        .length;
  }

  testWidgets('renders five circles with the rating filled', (tester) async {
    await tester.pumpWidget(themed(const RatingCircles(rating: 3)));

    expect(find.byType(RatingCircle), findsNWidgets(5));
    expect(countCircles(tester, filled: true), 3);
    expect(countCircles(tester, filled: false), 2);
  });

  testWidgets('selector reports the tapped rating', (tester) async {
    int? selected;
    await tester.pumpWidget(
      themed(RatingCircles(rating: 1, onChanged: (value) => selected = value)),
    );

    await tester.tap(find.byType(RatingCircle).at(3));

    expect(selected, 4);
  });
}
