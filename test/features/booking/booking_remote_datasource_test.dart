import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late BookingRemoteDatasource source;
  final requests = <String>[];
  final bodies = <Map<String, dynamic>>[];

  setUp(() async {
    requests.clear();
    bodies.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add('${request.method} ${request.uri}');
      if (request.method == 'POST') {
        bodies.add(
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>,
        );
      }
      final path = request.uri.path;
      if (path == '/api/v1/places/mira/coupons/check') {
        request.response.statusCode = 422;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'success': false,
            'message': 'Invalid coupon',
            'error': {'code': 'COUPON_INVALID', 'details': <String, dynamic>{}},
          }),
        );
        await request.response.close();
        return;
      }
      final data = switch (path) {
        '/api/v1/places/mira/availability/days' => [
          {
            'date': '2026-10-20',
            'label': 'Tuesday',
            'open': true,
            'slots_count': 1,
          },
        ],
        '/api/v1/places/mira/availability/slots' => [
          {
            'time': '16:00',
            'starts_at': '2026-10-20T16:00:00+03:00',
            'seats_left': 1,
            'staff': [
              {'id': 27, 'name': 'Reem'},
            ],
          },
        ],
        '/api/v1/places/mira/bookings' when request.method == 'GET' => [
          _booking,
        ],
        '/api/v1/places/mira/bookings' => _booking,
        '/api/v1/places/mira/bookings/2740' => _booking,
        '/api/v1/places/mira/bookings/2740/cancel' => {
          ..._booking,
          'status': 'cancelled',
        },
        _ => null,
      };
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'success': true,
          'message': 'OK',
          'data': data,
          if (request.method == 'GET' && path.endsWith('/bookings'))
            'meta': {'page': 1, 'last_page': 1},
        }),
      );
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
    source = BookingRemoteDatasource(DioClient(dio));
  });

  tearDown(() async => server.close(force: true));

  test(
    'loads availability and sends the selected slot in the booking payload',
    () async {
      final days = await source.getDays(40);
      final slots = await source.getSlots(40, days.single.date);
      final booking = await source.create(
        serviceId: 40,
        startsAt: slots.single.startsAt,
        staffId: slots.single.staff.single.id,
        notes: 'First visit',
      );

      expect(requests[0], contains('service_id=40'));
      expect(requests[0], contains('days=14'));
      expect(requests[1], contains('date=2026-10-20'));
      expect(bodies.single, containsPair('payment_method', 'cash'));
      expect(
        bodies.single,
        containsPair('starts_at', '2026-10-20T16:00:00+03:00'),
      );
      expect(bodies.single, containsPair('staff_id', 27));
      expect(booking.number, 'DR-1001');
      expect(booking.canCancel, isTrue);
    },
  );

  test('parses the list and detail, then sends cancellation reason', () async {
    final page = await source.getBookings();
    final detail = await source.getBooking(page.items.single.id);
    final cancelled = await source.cancel(detail.id, reason: 'Emergency');
    expect(page.lastPage, 1);
    expect(detail.serviceName, 'Makeup');
    expect(cancelled.status, 'cancelled');
    expect(bodies.single, containsPair('reason', 'Emergency'));
  });

  test('keeps the coupon rejection message', () async {
    await expectLater(
      source.checkCoupon('WELCOME10', 40),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Invalid coupon',
        ),
      ),
    );
    expect(bodies.single, {'code': 'WELCOME10', 'service_id': 40});
  });
}

const _booking = {
  'id': 2740,
  'number': 'DR-1001',
  'code': 'MF4TBW',
  'status': 'confirmed',
  'service_id': 40,
  'service_name': 'Makeup',
  'date': '2026-10-20',
  'time': '16:00',
  'starts_at': '2026-10-20T16:00:00+03:00',
  'can_cancel': true,
  'can_reschedule': false,
  'can_review': false,
  'timeline': <dynamic>[],
};
