import 'dart:io';

import 'package:e2ee_backend/e2ee_api.dart';
import 'package:e2ee_backend/e2ee_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Usage: dart run bin/server.dart [port] [data-file]
/// Defaults: port 8080, data file ./data.json.
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args[0]) : 8080;
  final file = File(args.length > 1 ? args[1] : 'data.json').absolute;
  final store = E2eeStore(file: file);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(e2eeApi(store, storageLabel: file.path));
  final server = await io.serve(handler, InternetAddress.loopbackIPv4, port);

  stdout
    ..writeln('Backend E2EE escuchando en http://localhost:${server.port}')
    ..writeln('Panel de administración: http://localhost:${server.port}/admin')
    ..writeln('Archivo de datos: ${file.path}');
}
