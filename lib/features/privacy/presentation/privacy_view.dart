import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../../boards/domain/board.dart';

/// Result of trying to open the shared collection as some account.
@immutable
class AccessResult {
  const AccessResult({
    required this.title,
    required this.granted,
    required this.lines,
  });

  final String title;
  final bool granted;
  final List<String> lines;
}

/// Plain data rendered by [PrivacyView].
@immutable
class PrivacyViewData {
  const PrivacyViewData({
    required this.syncedCount,
    required this.syncError,
    required this.adminUrl,
    required this.boards,
    required this.selectedBoardId,
    required this.includeNotes,
    required this.guestName,
    required this.sharedTitle,
    required this.guestHasAccess,
    required this.accessResult,
    required this.recoveryPhrase,
    required this.restoreResult,
    required this.busy,
  });

  final int syncedCount;

  /// Set when the backend could not be reached.
  final String? syncError;

  /// Admin panel of the backend, shown so the demo can open it.
  final String? adminUrl;
  final List<Board> boards;
  final String selectedBoardId;
  final bool includeNotes;
  final String guestName;
  final String? sharedTitle;
  final bool guestHasAccess;
  final AccessResult? accessResult;
  final String? recoveryPhrase;
  final AccessResult? restoreResult;
  final bool busy;
}

/// "Privacidad y cifrado": proof of concept of end-to-end encryption.
class PrivacyView extends StatefulWidget {
  const PrivacyView({
    super.key,
    required this.data,
    required this.onBack,
    required this.onOpenServer,
    required this.onRetrySync,
    required this.onSelectBoard,
    required this.onIncludeNotes,
    required this.onShare,
    required this.onOpenAsGuest,
    required this.onOpenAsIntruder,
    required this.onRevoke,
    required this.onEnableRecovery,
    required this.onRestore,
  });

  final PrivacyViewData data;
  final VoidCallback onBack;
  final VoidCallback onOpenServer;
  final VoidCallback onRetrySync;
  final ValueChanged<String> onSelectBoard;
  final ValueChanged<bool> onIncludeNotes;
  final VoidCallback onShare;
  final VoidCallback onOpenAsGuest;
  final VoidCallback onOpenAsIntruder;
  final VoidCallback onRevoke;
  final VoidCallback onEnableRecovery;
  final ValueChanged<String> onRestore;

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  final _phrase = TextEditingController();

  @override
  void dispose() {
    _phrase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final data = widget.data;
    final busy = data.busy;
    final shared = data.sharedTitle != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Privacidad y cifrado'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(s.screen, s.md, s.screen, s.xxxl),
        children: [
          if (busy) const LinearProgressIndicator(),
          _Section(
            icon: WanderIcons.lock,
            title: 'Tu diario cifrado',
            children: [
              Text(
                'Tus lugares, notas, valoraciones y fotos se cifran en este '
                'dispositivo antes de sincronizarse. El servidor solo guarda '
                'texto cifrado y no tiene la clave para leerlo.',
                style: tokens.text.body,
              ),
              SizedBox(height: s.md),
              Text(
                '${data.syncedCount} lugares cifrados en el servidor',
                style: tokens.text.bodyStrong,
              ),
              if (data.syncError != null) ...[
                SizedBox(height: s.sm),
                Text(
                  'No se pudo conectar con el servidor. ¿Está corriendo el '
                  'backend local?',
                  style: tokens.text.caption.copyWith(color: c.error),
                ),
                SizedBox(height: s.sm),
                _Own(
                  child: GhostButton(
                    label: 'Reintentar sincronización',
                    onPressed: widget.onRetrySync,
                  ),
                ),
              ],
              if (data.adminUrl case final url?) ...[
                SizedBox(height: s.md),
                Text(
                  'Compruébalo en el panel del servidor:',
                  style: tokens.text.caption,
                ),
                SelectableText(
                  url,
                  style: tokens.text.caption.copyWith(
                    fontFamily: 'monospace',
                    color: c.slate,
                  ),
                ),
                SizedBox(height: s.sm),
                _Own(
                  child: SecondaryButton(
                    label: 'Abrir panel del servidor',
                    icon: WanderIcons.lock,
                    onPressed: widget.onOpenServer,
                  ),
                ),
              ],
            ],
          ),
          _Section(
            icon: WanderIcons.link,
            title: 'Compartir una colección cifrada',
            children: [
              Text(
                'Solo las personas que elijas reciben la clave de la '
                'colección. Tus otras colecciones siguen privadas.',
                style: tokens.text.body,
              ),
              SizedBox(height: s.md),
              Wrap(
                spacing: s.sm,
                runSpacing: s.sm,
                children: [
                  for (final board in data.boards)
                    ChoiceChip(
                      label: Text(board.title),
                      selected: board.id == data.selectedBoardId,
                      onSelected: busy
                          ? null
                          : (_) => widget.onSelectBoard(board.id),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Incluir mis notas privadas'),
                value: data.includeNotes,
                onChanged: busy ? null : widget.onIncludeNotes,
              ),
              _Own(
                child: PrimaryButton(
                  label: 'Compartir con ${data.guestName}',
                  icon: WanderIcons.link,
                  onPressed: busy ? null : widget.onShare,
                ),
              ),
              if (shared) ...[
                SizedBox(height: s.md),
                Text(
                  data.guestHasAccess
                      ? '«${data.sharedTitle}» compartida con ${data.guestName}.'
                      : 'Acceso de ${data.guestName} revocado.',
                  style: tokens.text.bodyStrong,
                ),
                SizedBox(height: s.sm),
                _Own(
                  child: SecondaryButton(
                    label: 'Abrir como ${data.guestName}',
                    onPressed: busy ? null : widget.onOpenAsGuest,
                  ),
                ),
                SizedBox(height: s.sm),
                _Own(
                  child: SecondaryButton(
                    label: 'Abrir como cuenta no autorizada',
                    onPressed: busy ? null : widget.onOpenAsIntruder,
                  ),
                ),
                if (data.guestHasAccess) ...[
                  SizedBox(height: s.sm),
                  _Own(
                    child: GhostButton(
                      label: 'Revocar acceso de ${data.guestName}',
                      onPressed: busy ? null : widget.onRevoke,
                    ),
                  ),
                  Text(
                    'Revocar impide que vea versiones futuras; no borra lo '
                    'que ya haya visto o copiado.',
                    style: tokens.text.caption.copyWith(color: c.inkMuted),
                  ),
                ],
              ],
              if (data.accessResult case final result?) ...[
                SizedBox(height: s.md),
                _ResultCard(result: result),
              ],
            ],
          ),
          _Section(
            icon: WanderIcons.lock,
            title: 'Recuperación en otro teléfono',
            children: [
              Text(
                'El servidor no puede recuperar tus datos por ti. Guarda tu frase '
                'de recuperación: sin ella, un teléfono nuevo no puede leer '
                'tu diario.',
                style: tokens.text.body,
              ),
              SizedBox(height: s.md),
              if (data.recoveryPhrase case final phrase?) ...[
                Text('Tu frase de recuperación:', style: tokens.text.caption),
                SelectableText(
                  phrase,
                  key: const Key('recovery-phrase'),
                  style: tokens.text.titleM.copyWith(fontFamily: 'monospace'),
                ),
                SizedBox(height: s.md),
                TextField(
                  controller: _phrase,
                  decoration: const InputDecoration(
                    labelText: 'Frase en el teléfono nuevo',
                  ),
                ),
                SizedBox(height: s.sm),
                _Own(
                  child: PrimaryButton(
                    label: 'Recuperar en un teléfono nuevo',
                    onPressed: busy
                        ? null
                        : () => widget.onRestore(_phrase.text),
                  ),
                ),
              ] else
                _Own(
                  child: PrimaryButton(
                    label: 'Crear frase de recuperación',
                    onPressed: busy ? null : widget.onEnableRecovery,
                  ),
                ),
              if (data.restoreResult case final result?) ...[
                SizedBox(height: s.md),
                _ResultCard(result: result),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final radius = BorderRadius.circular(tokens.radii.md);
    // Material surface so the switch tile can paint its ink.
    return Container(
      margin: EdgeInsets.only(top: s.lg),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tokens.shadowSoft,
      ),
      child: Material(
        color: tokens.colors.card,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(s.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: tokens.colors.slate),
                  SizedBox(width: s.sm),
                  Expanded(child: Text(title, style: tokens.text.titleM)),
                ],
              ),
              SizedBox(height: s.md),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AccessResult result;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final color = result.granted ? tokens.colors.success : tokens.colors.error;
    return Container(
      padding: EdgeInsets.all(s.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radii.sm),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.granted ? Icons.lock_open : Icons.block,
                color: color,
              ),
              SizedBox(width: s.sm),
              Expanded(
                child: Text(result.title, style: tokens.text.bodyStrong),
              ),
            ],
          ),
          for (final line in result.lines) ...[
            SizedBox(height: s.xs),
            Text(line, style: tokens.text.caption),
          ],
        ],
      ),
    );
  }
}

/// Separate semantics node per button, so it is not merged into the card.
class _Own extends StatelessWidget {
  const _Own({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, child: child);
}
