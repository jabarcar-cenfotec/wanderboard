import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/theme/wander_tokens.dart';

/// Shows, raw, everything the simulated server stores (test T-01/T-08).
class ServerInspectorScreen extends StatelessWidget {
  const ServerInspectorScreen({super.key});

  static const _json = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final server = AppScope.of(context).e2ee.server;
    final tokens = context.wander;
    final s = tokens.spacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Vista del servidor')),
      body: ListenableBuilder(
        listenable: server,
        builder: (context, _) {
          final items = server.snapshot();
          return ListView.separated(
            padding: EdgeInsets.all(s.screen),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: s.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  'Esto es todo lo que guarda el servidor (simulado): '
                  '${items.length} elementos. No hay nombres de lugares, '
                  'notas ni claves privadas en claro.',
                  style: tokens.text.body,
                );
              }
              return Container(
                padding: EdgeInsets.all(s.md),
                decoration: BoxDecoration(
                  color: tokens.colors.card,
                  borderRadius: BorderRadius.circular(tokens.radii.sm),
                  border: Border.all(color: tokens.colors.line),
                ),
                child: SelectableText(
                  _json.convert(items[index - 1]),
                  style: tokens.text.caption.copyWith(fontFamily: 'monospace'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
