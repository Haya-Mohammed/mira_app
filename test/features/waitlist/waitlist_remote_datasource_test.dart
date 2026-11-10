import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/waitlist/data/waitlist_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late WaitlistRemoteDatasource source;
  final requests = <String>[];
  final bodies = <Map<String, dynamic>>[];

  setUp(() async {
    requests.clear();
    bodies.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add('${request.method} ${request.uri}');
      if (request.method == 'POST' && request.uri.path.endsWith('/waitlist')) {
        bodies.add(
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>,
        );
      }
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path.endsWith('/claim')) {
        request.response.statusCode = 422;
        request.response.write(
          jsonEncode({
            'success': false,
            'message': 'Offer expired',
            'status': 422,
            'error': {'code': 'OFFER_EXPIRED', 'details': <String, dynamic>{}},
          }),
        );
      } else if (request.method == 'DELETE') {
        request.response.write(
          jsonEncode({'success': true, 'message': 'Removed', 'data': null}),
        );
      } else {
        final list =
            request.method == 'GET' && request.uri.path.endsWith('/waitlist');
        request.response.write(
          jsonEncode({
            'success': true,
            'message': 'OK',
            'data': list ? [_entry] : _entry,
            if (list)
              'meta': {'page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
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
    source = WaitlistRemoteDatasource(DioClient(dio));
  });

  tearDown(() async => server.close(force: true));

  test('creates, lists, and loads an entry', () async {
    final created = await source.create(
      serviceId: 40,
      date: '2026-10-20',
      fromTime: '16:00',
      toTime: '20:00',
      notes: 'After work',
    );
    final page = await source.list();
    final detail = await source.get(created.id);

    expect(requests[0], 'POST /api/v1/places/mira/waitlist');
    expect(bodies.single, {
      'service_id': 40,
      'staff_id': null,
      'date': '2026-10-20',
      'from_time': '16:00',
      'to_time': '20:00',
      'notes': 'After work',
    });
    expect(requests[1], contains('active=1'));
    expect(page.items.single.service.name, 'Makeup');
    expect(detail.staff, isNull);
    expect(detail.canClaim, isFalse);
  });

  test('shows an expired claim and removes an entry', () async {
    await expectLater(
      source.claim(6),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Offer expired',
        ),
      ),
    );
    expect(await source.remove(6), 'Removed');
    expect(requests[0], 'POST /api/v1/places/mira/waitlist/6/claim');
    expect(requests[1], 'DELETE /api/v1/places/mira/waitlist/6');
  });
}

const _entry = {
  'id': 6,
  'status': 'waiting',
  'status_label': 'Waiting',
  'date': '2026-10-20',
  'from_time': '16:00',
  'to_time': '20:00',
  'notes': 'After work',
  'service': {'id': 40, 'name': 'Makeup'},
  'staff': null,
  'offer': null,
  'can_claim': false,
  'booking_id': null,
  'created_at': '2026-10-20T13:25:20+00:00',
};
