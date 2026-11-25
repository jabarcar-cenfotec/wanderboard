import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';

/// One incoming share, ready to render.
@immutable
class SofiaShareData {
  const SofiaShareData({
    required this.collectionId,
    required this.title,
    required this.lines,
    required this.lostAccess,
  });

  final String collectionId;

  /// Decrypted title, or null while the share is still closed.
  final String? title;
  final List<String> lines;
  final bool lostAccess;
}

/// Plain data rendered by [SofiaView].
@immutable
class SofiaViewData {
  const SofiaViewData({required this.shares, required this.error});

  final List<SofiaShareData> shares;

  /// Set when the backend could not be reached.
  final String? error;
}

/// "Teléfono de Sofía": the recipient side of the two-phone demo.
class SofiaView extends StatelessWidget {
  const SofiaView({super.key, required this.data, required this.onOpen});

  final SofiaViewData data;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Teléfono de Sofía')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(s.screen, s.md, s.screen, s.xxxl),
        children: [
          if (data.error != null)
            Text(
              'No se pudo conectar con el servidor. ¿Está corriendo el '
              'backend local?',
              style: tokens.text.caption.copyWith(color: c.error),
            ),
          if (data.shares.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: s.lg),
              child: Text(
                'Esperando que te compartan algo…',
                style: tokens.text.body.copyWith(color: c.inkMuted),
              ),
            ),
          for (final share in data.shares)
            _ShareCard(share: share, onOpen: () => onOpen(share.collectionId)),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.share, required this.onOpen});

  final SofiaShareData share;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;
    final radius = BorderRadius.circular(tokens.radii.md);

    return Container(
      margin: EdgeInsets.only(top: s.lg),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tokens.shadowSoft,
      ),
      child: Material(
        color: c.card,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(s.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(WanderIcons.link, color: c.slate),
                  SizedBox(width: s.sm),
                  Expanded(
                    child: Text(
                      'Te compartieron una colección',
                      style: tokens.text.titleM,
                    ),
                  ),
                ],
              ),
              SizedBox(height: s.md),
              if (share.lostAccess)
                Text(
                  'Ya no tienes acceso a esta colección.',
                  style: tokens.text.bodyStrong.copyWith(color: c.error),
                )
              else if (share.title case final title?) ...[
                Text('«$title»', style: tokens.text.bodyStrong),
                for (final line in share.lines) ...[
                  SizedBox(height: s.xs),
                  Text(line, style: tokens.text.caption),
                ],
              ] else
                Semantics(
                  container: true,
                  child: PrimaryButton(label: 'Abrir', onPressed: onOpen),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
