import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../application/e2ee_device.dart';
import '../application/e2ee_environment.dart';
import '../domain/e2ee_errors.dart';
import '../domain/encrypted_models.dart';
import 'privacy_view.dart';

/// Container for the E2EE proof of concept.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String? _boardId;
  bool _includeNotes = false;
  bool _busy = false;
  AccessResult? _access;
  AccessResult? _restore;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openAs(E2eeEnvironment e2ee, E2eeDevice device, String who) =>
      _run(() async {
        AccessResult result;
        try {
          final content = await e2ee.openAs(device);
          result = AccessResult(
            title: '$who descifró «${content.title}»',
            granted: true,
            lines: [for (final place in content.places) _describe(place)],
          );
        } on E2eeAccessDenied {
          result = AccessResult(
            title: '$who no puede abrir la colección',
            granted: false,
            lines: const [
              'El servidor no tiene una clave cifrada para esta cuenta.',
            ],
          );
        } on E2eeIntegrityError {
          result = AccessResult(
            title: '$who no puede abrir la colección',
            granted: false,
            lines: const ['La clave no descifra el contenido.'],
          );
        }
        _access = result;
      });

  static String _describe(SharedPlace place) {
    final note = place.note.isEmpty ? 'sin nota' : 'nota: «${place.note}»';
    return '• ${place.name} — ${place.location} ($note)';
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final e2ee = scope.e2ee;
    final boards = scope.boards.all();
    final boardId = _boardId ?? boards.first.id;

    return ListenableBuilder(
      listenable: e2ee,
      builder: (context, _) => PrivacyView(
        data: PrivacyViewData(
          syncedCount: e2ee.syncedCount,
          syncError: e2ee.syncError,
          adminUrl: e2ee.adminUrl?.toString(),
          boards: boards,
          selectedBoardId: boardId,
          includeNotes: _includeNotes,
          guestName: guestName,
          sharedTitle: e2ee.sharedTitle,
          guestHasAccess: e2ee.guestHasAccess,
          accessResult: _access,
          recoveryPhrase: e2ee.recoveryPhrase,
          restoreResult: _restore,
          busy: _busy,
          remoteGuest: e2ee.hasRemoteGuest,
        ),
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.profile),
        onOpenServer: () {
          final url = e2ee.adminUrl;
          if (url != null) launchUrl(url, webOnlyWindowName: '_blank');
        },
        onRetrySync: e2ee.retrySync,
        onSelectBoard: (id) => setState(() => _boardId = id),
        onIncludeNotes: (value) => setState(() => _includeNotes = value),
        onShare: () => _run(() async {
          final board = scope.boards.byId(boardId)!;
          final shared = await e2ee.shareWithGuest(
            collectionTitle: board.title,
            places: scope.places.inBoard(board.id),
            includeNotes: _includeNotes,
          );
          _access = shared
              ? null
              : const AccessResult(
                  title: 'El teléfono de Sofía aún no está conectado.',
                  granted: false,
                  lines: ['Abre la app con ?rol=sofia y vuelve a compartir.'],
                );
        }),
        onOpenAsGuest: () => _openAs(e2ee, e2ee.guest, guestName),
        onOpenAsIntruder: () =>
            _openAs(e2ee, e2ee.intruder, 'La cuenta no autorizada'),
        onRevoke: () => _run(() async {
          await e2ee.revokeGuest();
          _access = null;
        }),
        onEnableRecovery: () => _run(e2ee.enableRecovery),
        onRestore: (phrase) => _run(() async {
          try {
            final places = await e2ee.restoreOnNewDevice(phrase);
            _restore = AccessResult(
              title: 'Teléfono nuevo: ${places.length} lugares recuperados',
              granted: true,
              lines: [for (final place in places.take(3)) '• ${place.name}'],
            );
          } on E2eeRecoveryFailed {
            _restore = const AccessResult(
              title: 'Frase incorrecta',
              granted: false,
              lines: [
                'Sin la frase correcta no se pueden descifrar los datos.',
              ],
            );
          }
        }),
      ),
    );
  }
}
