import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'admin_page.dart';
import 'e2ee_store.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

/// HTTP API used by the app, plus the admin panel.
///
///   PUT/GET /keys/{account}
///   PUT     /records/{owner}/{record}    GET /records/{owner}
///   PUT/GET /collections/{id}            GET /collections/{id}/grants/{account}
///   PUT/GET /recovery/{account}
///   GET     /admin, /admin/data, /admin/search?q=   POST /admin/reset
Handler e2eeApi(E2eeStore store, {String storageLabel = 'memoria'}) {
  return (Request request) async {
    if (request.method == 'OPTIONS') {
      return Response(204, headers: _corsHeaders);
    }
    final segments = request.url.pathSegments;
    final route = (request.method, segments);

    Future<Object?> body() async => jsonDecode(await request.readAsString());

    switch (route) {
      case ('GET', [] || ['admin']):
        return Response.ok(
          adminPage,
          headers: {'Content-Type': 'text/html; charset=utf-8'},
        );
      case ('GET', ['admin', 'data']):
        return _json({'storage': storageLabel, 'data': store.snapshot()});
      case ('GET', ['admin', 'search']):
        final query = request.url.queryParameters['q'] ?? '';
        return _json({
          'query': query,
          'matches': query.isEmpty
              ? 0
              : query.allMatches(store.rawText()).length,
        });
      case ('POST', ['admin', 'reset']):
        store.reset();
        return _json({'ok': true});

      case ('PUT', ['keys', final account]):
        store.putPublicKey(account, await body());
        return _json({'ok': true});
      case ('GET', ['keys', final account]):
        return _jsonOr404(store.publicKey(account));

      case ('PUT', ['records', final owner, final record]):
        store.putRecord(owner, record, await body());
        return _json({'ok': true});
      case ('GET', ['records', final owner]):
        return _json(store.records(owner));

      case ('PUT', ['collections', final id]):
        store.putCollection(id, await body());
        return _json({'ok': true});
      case ('GET', ['collections', final id]):
        return _jsonOr404(store.collection(id));
      case ('GET', ['collections', final id, 'grants', final account]):
        return _jsonOr404(store.grant(id, account));

      case ('PUT', ['recovery', final account]):
        store.putRecoveryBackup(account, await body());
        return _json({'ok': true});
      case ('GET', ['recovery', final account]):
        return _jsonOr404(store.recoveryBackup(account));
    }
    return Response.notFound('Not found', headers: _corsHeaders);
  };
}

Response _json(Object? value) => Response.ok(
  jsonEncode(value),
  headers: {..._corsHeaders, 'Content-Type': 'application/json'},
);

Response _jsonOr404(Object? value) => value == null
    ? Response.notFound('null', headers: _corsHeaders)
    : _json(value);
