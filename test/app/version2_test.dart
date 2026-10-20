import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/core/utils/date_format.dart';
import 'package:wanderboard/features/places/presentation/place_detail_screen.dart';
import 'package:wanderboard/shared/widgets/atoms/tag_chip.dart';

import '../helpers/pump_app.dart';

/// Changes of prototype version 2 (Fase 6, section 6.2).
void main() {
  Finder editorForm() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  Future<void> tapInForm(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(target, 200, scrollable: editorForm());
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, String label) async {
    await tester.pump();
    await tester.tap(find.text(label));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> openPlace(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(
      find.text(name),
      200,
      scrollable: verticalScroll(),
    );
    // Keep the row clear of the bottom navigation bar.
    await tester.ensureVisible(find.text(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> addPlace(
    WidgetTester tester, {
    required String name,
    String? type,
    String? address,
  }) async {
    await tester.tap(find.bySemanticsLabel('Agregar lugar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del lugar'),
      name,
    );
    if (address != null) {
      await tester.enterText(
        find.widgetWithText(TextField, 'Dirección (opcional)'),
        address,
      );
    }
    if (type != null) await tapInForm(tester, find.text(type));
    await save(tester, 'Guardar');
  }

  Finder detailScroll() => find
      .descendant(
        of: find.byType(PlaceDetailScreen),
        matching: find.byType(Scrollable),
      )
      .first;

  bool chipSelected(WidgetTester tester, String label) => tester
      .widget<TagChip>(find.widgetWithText(TagChip, label).first)
      .selected;

  testWidgets('S1: the diary asks for the name and labels sample places', (
    tester,
  ) async {
    await pumpWanderApp(tester);

    await tester.tap(find.text('Empezar mi diario'));
    await tester.pumpAndSettle();
    expect(find.text('Tu diario privado de lugares'), findsOneWidget);

    await enterDiary(tester, name: 'Rosa');
    expect(find.textContaining('Rosa'), findsOneWidget);
    expect(find.textContaining('Joana'), findsNothing);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Ejemplo'), findsWidgets);
  });

  testWidgets('S2: a place type can be chosen, filtered and searched', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await addPlace(tester, name: 'Soda La Casona', type: 'Restaurante');
    expect(chipSelected(tester, 'Pendientes'), isTrue);

    await tester.tap(find.widgetWithText(TagChip, 'Restaurante'));
    await tester.pumpAndSettle();
    expect(find.text('Soda La Casona'), findsOneWidget);
    expect(find.text('Catarata del Toro'), findsNothing);

    await tester.tap(find.widgetWithText(TagChip, 'Todos'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar en mis lugares'),
      'restaurante',
    );
    await tester.pumpAndSettle();
    expect(find.text('Soda La Casona'), findsOneWidget);
    expect(find.text('Catarata del Toro'), findsNothing);
  });

  testWidgets('S3: the save button is visible without scrolling', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await tester.tap(find.bySemanticsLabel('Agregar lugar'));
    await tester.pumpAndSettle();
    expect(find.text('Guardar').hitTestable(), findsOneWidget);
  });

  testWidgets('S4, S6, S7: registering a visit with stars and another date', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    await openPlace(tester, 'Catarata del Toro');

    // S7: the action is on top and the duplicated pencil is gone.
    expect(find.text('Registrar visita').hitTestable(), findsOneWidget);
    expect(find.byTooltip('Editar registro'), findsNothing);
    await tester.tap(find.text('Registrar visita'));
    await tester.pumpAndSettle();

    // S4: stars with the label of the chosen value.
    await tapInForm(tester, find.bySemanticsLabel('4 estrellas'));
    expect(find.text('Muy bueno'), findsOneWidget);

    // S6: the visit date can be changed.
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month);
    await tapInForm(tester, find.text('Cambiar fecha'));
    await tester.tap(
      find
          .descendant(
            of: find.byType(DatePickerDialog),
            matching: find.text('1'),
          )
          .first,
    );
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    expect(find.text(formatVisitDate(firstOfMonth)), findsOneWidget);

    await save(tester, 'Guardar cambios');
    expect(find.text('Muy bueno'), findsOneWidget);
    expect(
      find.text('Visitado el ${formatVisitDate(firstOfMonth)}'),
      findsOneWidget,
    );
  });

  testWidgets('S5: the address is kept and opens in Google Maps or Waze', (
    tester,
  ) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await addPlace(
      tester,
      name: 'Soda La Casona',
      address: '200 m norte de la iglesia',
    );
    await openPlace(tester, 'Soda La Casona');
    await tester.scrollUntilVisible(
      find.text('Abrir en Waze'),
      200,
      scrollable: detailScroll(),
    );
    expect(find.textContaining('200 m norte de la iglesia'), findsOneWidget);
    expect(find.text('Abrir en Google Maps'), findsOneWidget);
    expect(find.text('Abrir en Waze'), findsOneWidget);
  });

  testWidgets('S8: the search respects the active list', (tester) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar en mis lugares'),
      'costa rica',
    );
    await tester.pumpAndSettle();
    expect(find.text('Catarata del Toro'), findsOneWidget);
    expect(find.text('Canales de Tortuguero'), findsNothing);
  });

  testWidgets('S9: saving shows where the place was saved', (tester) async {
    await pumpWanderApp(tester);
    await enterDiary(tester);

    await addPlace(tester, name: 'Volcán Poás');
    expect(find.text('«Volcán Poás» se guardó en Pendientes'), findsOneWidget);
  });
}
