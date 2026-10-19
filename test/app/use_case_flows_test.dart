import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/features/places/presentation/place_detail_screen.dart';
import 'package:wanderboard/shared/widgets/atoms/tag_chip.dart';

import '../helpers/pump_app.dart';

/// The three use cases validated with users in Fase 5 (Fase 3, section 3.5).
void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.text('Empezar mi diario'));
    await tester.pumpAndSettle();
  }

  Finder editorForm() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  Future<void> tapInForm(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(target, 200, scrollable: editorForm());
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
  }

  Future<void> waitForSavedDialog(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Guardado en tu diario'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> openPlace(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(find.text(name), 200);
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Finder detailScroll() => find
      .descendant(
        of: find.byType(PlaceDetailScreen),
        matching: find.byType(Scrollable),
      )
      .first;

  Future<void> showList(WidgetTester tester, String list) async {
    await tester.scrollUntilVisible(find.text(list), -200);
    await tester.tap(find.text(list));
    await tester.pumpAndSettle();
  }

  bool chipSelected(WidgetTester tester, String label) => tester
      .widget<TagChip>(find.widgetWithText(TagChip, label).first)
      .selected;

  testWidgets('CU-01: a pending place is saved with only its name', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.bySemanticsLabel('Agregar lugar'));
    await tester.pumpAndSettle();
    expect(find.text('Agregar lugar'), findsWidgets);
    expect(chipSelected(tester, 'Quiero visitar'), isTrue);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del lugar'),
      'Volcán Poás',
    );
    await tapInForm(tester, find.text('Guardar'));
    await waitForSavedDialog(tester);

    // Lands on "Mis lugares", list of pending places.
    expect(chipSelected(tester, 'Pendientes'), isTrue);
    expect(find.text('Volcán Poás'), findsOneWidget);
  });

  testWidgets('CU-01: a place without a name cannot be saved', (tester) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.bySemanticsLabel('Agregar lugar'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Agrega el nombre del lugar para guardar.'),
      200,
      scrollable: editorForm(),
    );
    expect(
      find.text('Agrega el nombre del lugar para guardar.'),
      findsOneWidget,
    );
  });

  testWidgets('CU-02: registering a visit updates status, note and history', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    await openPlace(tester, 'Catarata del Toro');
    expect(find.byType(PlaceDetailScreen), findsOneWidget);
    expect(find.text('Quiero visitar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Registrar visita'),
      200,
      scrollable: detailScroll(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar visita'));
    await tester.pumpAndSettle();
    expect(chipSelected(tester, 'Ya visité'), isTrue);

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Me la recomendaron en el trabajo. '
        'Ir temprano y con zapatos para barro.',
      ),
      'La catarata impresiona; el sendero de bajada es exigente.',
    );
    await tapInForm(tester, find.text('Guardar cambios'));
    await waitForSavedDialog(tester);

    // Back on the detail with the updated record.
    expect(find.text('Ya visité'), findsOneWidget);
    expect(find.textContaining('Visitado el'), findsOneWidget);
    expect(
      find.text('La catarata impresiona; el sendero de bajada es exigente.'),
      findsOneWidget,
    );
    expect(find.text('Registrar visita'), findsNothing);

    // The place moved from "Pendientes" to "Historial".
    await tester.drag(detailScroll(), const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Catarata del Toro'), findsNothing);
    await showList(tester, 'Historial');
    await tester.scrollUntilVisible(find.text('Catarata del Toro'), 200);
    expect(find.text('Catarata del Toro'), findsOneWidget);
  });

  testWidgets('CU-03: a saved place is found by list and by collection', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    await openPlace(tester, 'Canales de Tortuguero');
    expect(find.text('Quiero volver'), findsOneWidget);
    expect(find.textContaining('Bote en silencio al amanecer'), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await showList(tester, 'Colecciones');
    await tester.tap(find.text('Costa Rica sin prisa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Catarata del Toro'), 200);
    expect(find.text('Catarata del Toro'), findsOneWidget);
  });
}
