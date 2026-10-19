Objective: align the Wanderboard prototype (v1) with the use cases, userflows and requirements of Fase 3 of "Avance 1 Proyecto current.docx".
Branch: fase4V1 (from v0-baseline). Delivery: local commits only, tag v1. Test runner: `flutter test`, plus `flutter analyze`.

## Specs

- S1 (RF-01, CU-01): "La aplicación permitirá registrar un lugar." / "El usuario puede crear un registro con al menos el nombre del lugar y guardarlo."
- S2 (RF-02): "La aplicación permitirá asignar un estado personal al lugar." States: "Quiero visitar", "Ya visité", "Quiero volver", "No volvería".
- S3 (RF-03, CU-02): "La aplicación permitirá modificar el estado de un lugar existente." / "El estado actualizado se refleja en el registro y en la vista de consulta correspondiente." Userflow CU-02: "Abrir detalle → Elegir “Registrar visita” o editar el registro → Cambiar estado a “Ya visité” → Añadir comentario personal → Añadir valoración y fotografía de forma opcional → Guardar cambios".
- S4 (RF-04..RF-06): note, photo and rating are optional and stay attached to the right place.
- S5 (RF-07, RF-08, CU-03): "Abrir “Mis lugares” → Elegir lista de pendientes, historial o colección → Revisar los lugares disponibles → Seleccionar un lugar → Consultar ubicación, estado y experiencia registrada".
- S6 (CU-01 userflow): "Acceder a “Mis lugares” → Seleccionar “Agregar lugar” → Ingresar nombre y datos disponibles → Asignar categoría/ubicación si aplica → Seleccionar estado “Quiero visitar” → Guardar → Ver confirmación → Lugar visible en la lista de pendientes."
- S7 (RNF Consistencia/Usabilidad): "Usar los mismos nombres para estados y acciones en todas las pantallas." UI copy in Spanish using the userflow names.
- S8 (RF-09): "El flujo no publica automáticamente comentarios, fotografías ni valoraciones para otros usuarios." Share stays as-is, out of the tested flows.

## Tasks

- T1 [S2,S4] PlaceStatus model, optional visit date, seed data with pending places — inline — done
- T2 [S1,S2,S6] Editor: status selector, save with name only, "Agregar lugar" — inline — done
- T3 [S3] Place detail: "Registrar visita" action, status shown — inline — done
- T4 [S5,S6] "Mis lugares" view with Pendientes / Historial filters — inline — done
- T5 [S7] Spanish UI copy — inline — done
- T6 [S1-S8] Tests for CU-01..CU-03, analyze, suite — inline — done

## Log

- L1 (2026-10-19, user): "no, a partir de esta version vamos a hacer un branch, llamado fase4V1, para no perder el original, y haremos lo que la fase cuatro pide en base a la fase 3"
- L2: Baseline commit 14dc363 tagged v0-baseline; branch fase4V1 created. Route: inline (no writer trigger: units depend on the shared Place model).
- L3: T1-T6 done. RED observed for PlaceStatus tests before implementation; suite GREEN: `flutter test` 27 passed (baseline 17), `flutter analyze` no issues, `flutter build web --release` built. New: place_list.dart, place_row_card.dart, use_case_flows_test.dart (CU-01 x2, CU-02, CU-03), place_status_test.dart. Share label shortened to "Copiar" to avoid overflow. Single commit (~1.1k lines) because the Spanish copy and the status feature touch the same widgets; local-only repo.
- L4: Next: tag v1, deploy build/web to Azure site 1, update Fase 4 link in the document.
- L5: Ran build/web in Edge (localhost:8080): onboarding, Mis lugares/Pendientes, detail, Registrar visita editor verified visually. Fixed leftover English (board notes, '6 places', profile motto) in a65a0dc; v1 tag moved there. 27 tests pass. User will deploy build/web with their enterprise Azure account.
