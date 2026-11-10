import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/direct/data/queue_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late QueueRemoteDatasource source;
  final requests = <String>[];
  final bodies = <Map<String, dynamic>>[];

  setUp(() async {
    requests.clear();
    bodies.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add('${request.method} ${request.uri.path}');
      if (request.method == 'POST' && request.uri.path.endsWith('/tickets')) {
        bodies.add(
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>,
        );
      }
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path.endsWith('/my-ticket')) {
        request.response.write(
          jsonEncode({'success': true, 'message': 'تم بنجاح', 'data': null}),
        );
      } else if (request.method == 'POST' &&
          request.uri.path.endsWith('/tickets')) {
        request.response.statusCode = 422;
        request.response.write(
          jsonEncode({
            'success': false,
            'message': 'الدور الحي غير مفعّل في هذه المنشأة',
            'status': 422,
            'error': {'code': 'QUEUE_DISABLED', 'details': {}},
          }),
        );
      } else if (request.method == 'POST') {
        request.response.statusCode = 404;
        request.response.write(
          jsonEncode({
            'success': false,
            'message': 'الرابط المطلوب غير موجود',
            'status': 404,
            'error': {'code': 'NOT_FOUND', 'details': {}},
          }),
        );
      } else {
        request.response.write(
          jsonEncode({
            'success': true,
            'message': 'تم بنجاح',
            'data': {
              'enabled': false,
              'open': true,
              'accepting': false,
              'date': '2026-10-20',
              'now_serving': [],
              'waiting_count': 0,
              'next': [],
              'served_today': 0,
              'average_minutes': 15,
              'counters': 4,
              'estimated_wait_minutes': 4,
              'updated_at': '2026-10-20T13:46:00+00:00',
            },
          }),
        );
      }
      await request.response.close();
    });
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.path = 'http://127.0.0.1:${server.port}${options.uri.path}';
          handler.next(options);
        },
      ),
    );
    source = QueueRemoteDatasource(DioClient(dio));
  });

  tearDown(() async => server.close(force: true));

  test('reads status and null my-ticket', () async {
    final status = await source.getStatus();
    final ticket = await source.getMyTicket();
    expect(status.enabled, isFalse);
    expect(status.open, isTrue);
    expect(status.accepting, isFalse);
    expect(status.estimatedWaitMinutes, 4);
    expect(ticket, isNull);
    expect(requests, [
      'GET /api/v1/places/mira/queue',
      'GET /api/v1/places/mira/queue/my-ticket',
    ]);
  });

  test('posts nullable service and preserves disabled error', () async {
    await expectLater(
      source.createTicket(),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'الدور الحي غير مفعّل في هذه المنشأة',
        ),
      ),
    );
    expect(bodies.single, {'service_id': null});
    expect(requests.single, 'POST /api/v1/places/mira/queue/tickets');
  });

  test('cancel uses ticket id and preserves not-found error', () async {
    await expectLater(
      source.cancelTicket(42),
      throwsA(
        isA<NotFoundException>().having(
          (e) => e.message,
          'message',
          'الرابط المطلوب غير موجود',
        ),
      ),
    );
    expect(requests.single, 'POST /api/v1/places/mira/queue/tickets/42/cancel');
  });
}
