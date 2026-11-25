import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../application/sofia_phone.dart';
import 'sofia_view.dart';

/// Path of the recipient phone screen of the two-phone demo.
const sofiaRoute = '/telefono-sofia';

/// Container for the recipient phone: reads the inbox state and opens
/// shares on request.
class SofiaScreen extends StatelessWidget {
  const SofiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = AppScope.of(context).sofia!;
    return ListenableBuilder(
      listenable: phone,
      builder: (context, _) => SofiaView(
        data: SofiaViewData(
          error: phone.error,
          shares: [for (final share in phone.shares) _describe(share)],
        ),
        onOpen: phone.open,
      ),
    );
  }

  static SofiaShareData _describe(IncomingShare share) {
    final content = share.content;
    return SofiaShareData(
      collectionId: share.collectionId,
      title: content?.title,
      lines: [
        for (final place in content?.places ?? const [])
          '• ${place.name} — ${place.location}'
              '${place.note.isEmpty ? '' : ' (nota: «${place.note}»)'}',
      ],
      lostAccess: share.lostAccess,
    );
  }
}
