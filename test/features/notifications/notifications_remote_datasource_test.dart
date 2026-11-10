import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/notifications/data/notifications_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads empty page metadata and marks all notifications read', () async {
    final requests = <String>[];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      requests.add(
        '${request.method} ${request.uri.path}?${request.uri.query}',
      );
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode(
          request.method == 'GET'
              ? {
                  'success': true,
                  'message': 'تم بنجاح',
                  'data': [],
                  'meta': {
                    'page': 1,
                    'per_page': 20,
                    'total': 0,
                    'last_page': 1,
                    'unread': 0,
                  },
                }
              : {
                  'success': true,
                  'message': 'تم بنجاح',
                  'data': {'unread': 0},
                },
        ),
      );
      await request.response.close();
    });
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final uri = Uri.parse(options.path);
            options.path = uri
                .replace(scheme: 'http', host: '127.0.0.1', port: server.port)
                .toString();
            handler.next(options);
          },
        ),
      );
    final source = NotificationsRemoteDatasource(DioClient(dio));
    final page = await source.getNotifications();
    expect(page.items, isEmpty);
    expect(page.perPage, 20);
    expect(page.lastPage, 1);
    expect(page.unread, 0);
    expect(await source.readAll(), 0);
    expect(requests, [
      'GET /api/v1/places/mira/notifications?page=1',
      'POST /api/v1/places/mira/notifications/read-all?',
    ]);
  });
}
