import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const user = <String, dynamic>{
  'id': 74,
  'name': 'Test User',
  'email': 'test@example.com',
  'phone': '0599000111',
  'role': 'customer',
  'role_label': 'Customer',
  'avatar': null,
  'initials': 'TU',
  'cohort': null,
  'is_active': true,
  'last_login_at': null,
  'created_at': '2026-10-19T07:22:31+00:00',
};

void main() {
  late HttpServer server;
  late AuthRemoteDatasourceImpl source;
  final requests = <String>[];
  final bodies = <Map<String, dynamic>>[];
  final headers = <String?>[];

  setUp(() async {
    requests.clear();
    bodies.clear();
    headers.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add('${request.method} ${request.uri.path}');
      headers.add(request.headers.value('authorization'));
      final raw = await utf8.decoder.bind(request).join();
      if (raw.isNotEmpty) bodies.add(jsonDecode(raw) as Map<String, dynamic>);
      final path = request.uri.path;
      final response = switch (path) {
        '/api/v1/places/mira/auth/login' =>
          bodies.last['password'] == 'wrong'
              ? {'message': 'Invalid credentials'}
              : {
                  'success': true,
                  'data': {'token': '42|secret', 'user': user},
                },
        '/api/v1/places/mira/auth/register' => {
          if (bodies.last['email'] == 'taken@example.com') ...{
            'message': 'Please check your details',
            'errors': {
              'email': ['Email is taken'],
            },
          } else ...{
            'success': true,
            'data': {'token': '43|secret', 'user': user},
          },
        },
        '/api/v1/places/mira/auth/me' => {
          'success': true,
          'data': {
            ...user,
            'reliability': {
              'score': 100,
              'level': 'new',
              'label': 'New customer',
              'completed': 0,
              'no_shows': 0,
              'late_cancellations': 0,
              'total': 0,
            },
          },
        },
        '/api/v1/places/mira/auth/profile' => {'success': true, 'data': user},
        '/api/v1/places/mira/auth/logout' => {
          'success': true,
          'message': 'تم تسجيل الخروج',
          'data': null,
        },
        _ => {'success': false},
      };
      if (path.endsWith('/login') && bodies.last['password'] == 'wrong') {
        request.response.statusCode = 401;
      }
      if (path.endsWith('/register') &&
          bodies.last['email'] == 'taken@example.com') {
        request.response.statusCode = 422;
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      await request.response.close();
    });
    source = AuthRemoteDatasourceImpl(DioClient(Dio()));
  });

  tearDown(() => server.close(force: true));

  test('sends all auth payloads and parses session and profile responses', () async {
    // EndPoints are absolute, so rewrite them to the local server in this test.
    final dio = Dio()..interceptors.add(_LocalHostInterceptor(server.port));
    source = AuthRemoteDatasourceImpl(DioClient(dio));
    final session = await source.login('test@example.com', 'password123');
    expect(session.token, '42|secret');
    expect(session.user.id, 74);
    final registered = await source.register(
      'Test User',
      'test@example.com',
      '0599000111',
      'password123',
      'password123',
    );
    expect(registered.user.name, 'Test User');
    final me = await source.me();
    expect(me.reliability?.score, 100);
    await source.updateProfile('Test User', 'test@example.com', '0599000111');
    expect(requests, [
      'POST /api/v1/places/mira/auth/login',
      'POST /api/v1/places/mira/auth/register',
      'GET /api/v1/places/mira/auth/me',
      'PUT /api/v1/places/mira/auth/profile',
    ]);
    expect(bodies[0]['device_name'], 'booking_app');
    expect(bodies[1]['password_confirmation'], 'password123');
    expect(bodies[2]['phone'], '0599000111');
    expect(headers, everyElement(isNull));
  });

  test('maps an invalid login to unauthorized exception', () async {
    final dio = Dio()..interceptors.add(_LocalHostInterceptor(server.port));
    source = AuthRemoteDatasourceImpl(DioClient(dio));
    expect(
      () => source.login('test@example.com', 'wrong'),
      throwsA(isA<UnauthorizedException>()),
    );
  });

  test('preserves API validation errors by field', () async {
    final dio = Dio()..interceptors.add(_LocalHostInterceptor(server.port));
    source = AuthRemoteDatasourceImpl(DioClient(dio));
    try {
      await source.register(
        'Test User',
        'taken@example.com',
        '0599000111',
        'password123',
        'password123',
      );
      fail('Expected validation failure');
    } on ValidationException catch (error) {
      expect(error.fieldErrors['email'], 'Email is taken');
    }
  });

  test('posts authenticated logout and accepts null data', () async {
    final dio = Dio()..interceptors.add(_LocalHostInterceptor(server.port));
    source = AuthRemoteDatasourceImpl(DioClient(dio));
    await source.logout();
    expect(requests, ['POST /api/v1/places/mira/auth/logout']);
  });
}

class _LocalHostInterceptor extends Interceptor {
  _LocalHostInterceptor(this.port);
  final int port;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = Uri.parse(options.path);
    options.path = uri
        .replace(scheme: 'http', host: '127.0.0.1', port: port)
        .toString();
    handler.next(options);
  }
}
