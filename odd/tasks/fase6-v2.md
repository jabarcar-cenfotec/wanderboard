Objective: build prototype version 2 with the changes listed in section "6.2. Versión 2" of "Avance 1 Proyecto current.docx" (Fase 6), keeping v1 intact.
Branch: fase6V2 (from fase4V1, tag v1 = e73418c). Delivery: local commits only, tag v2. Test runner: `flutter test`, plus `flutter analyze`.

## Specs

Quoted verbatim from the "Cambio en la versión 2" table of section 6.2:

- S1 (H1): "Al iniciar, la aplicación solicita el nombre de la persona; los lugares precargados se identifican como ejemplos."
- S2 (H2): "Campo «Tipo de lugar» en el formulario, filtro por tipo en «Mis lugares» y búsqueda que incluye el tipo."
- S3 (H3): "Botón «Guardar» fijo y siempre visible."
- S4 (H4): "Valoración con estrellas y etiqueta del valor elegido."
- S5 (H5): "Campo de dirección y botón para abrir la ubicación en Google Maps o Waze."
- S6 (H6): "Fecha de visita editable."
- S7 (H8, H9): "«Registrar visita» en la parte superior de la ficha; se elimina el ícono de lápiz duplicado."
- S8 (H11): "La búsqueda respeta el filtro activo."
- S9 (H12): "Mensaje de confirmación al guardar."
- S10: v1 behavior not listed above (CU-01..CU-03 flows, statuses, collections) keeps working; existing tests stay green.

Out of scope (section 6.2): H7, H10, cloud accounts, import from social networks.

## Tasks

- T1 [S2,S5,S6] Model: place type, address, editable visit date in Place/ReviewDraft/SaveReview + seed data — inline — done
- T2 [S1] Onboarding asks the name; greeting uses it; seed places labeled as examples — inline — done
- T3 [S2,S3,S4,S5,S6,S9] Editor: type selector, address, date picker, star rating with label, pinned save button, confirmation — inline — done
- T4 [S5,S7] Place detail: "Registrar visita" on top, no pencil, open in Google Maps / Waze — inline — done
- T5 [S2,S8] Mis lugares: type filter, search includes type and respects active list — inline — done
- T6 [S10] Tests, analyze, web build, visual check — inline — done

## Log

- L1 (2026-10-20, user): "genera un branch y has la v2"
- L2: Scope = the 6.2 table already approved in the document (user: "implementa primero la documentacion de fase 6", then "genera un branch y has la v2"). Route: inline (no writer trigger: all units share the Place model and editor). Branch fase6V2 created from fase4V1.
- L3: RED observed: new tests (version2_test.dart S1-S9, place_links_test.dart) failed to compile / find widgets before implementation. GREEN: `flutter test` 42 passed (v1 had 34; rating_circles_test removed with RatingCircles, replaced by StarRating), `flutter analyze` no issues, `flutter build web --release` built.
- L4: Existing v1 tests adjusted only for layout: shared `enterDiary` helper (name now required), scroll to off-screen note fields, rows kept clear of the bottom bar before tapping.
- L5: New dependencies: url_launcher (open Google Maps / Waze), flutter_localizations (Spanish date picker, locale es). Visual check in Edge (430x932): onboarding with name, greeting "Buenos días, Rosa", Pendientes with type filter and "Ejemplo" labels, detail with "Registrar visita" on top and Maps/Waze buttons, editor with date, stars and pinned "Guardar cambios", date picker in Spanish.
