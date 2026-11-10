import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends DioClient {
  _Client(this.response) : super(Dio());
  final Object? response;
  String? requestedPath;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    requestedPath = path;
    return response;
  }
}

void main() {
  test('reads the place home endpoint and parses featured services', () async {
    final client = _Client({
      'success': true,
      'message': 'OK',
      'data': {
        'place': {'id': 18, 'name': 'Mira', 'slug': 'mira'},
        'featured': [
          {'id': 2, 'name': 'Hair', 'slug': 'hair'},
        ],
      },
    });
    final data = await HomeRemoteDatasourceImpl(client).getHome();
    expect(client.requestedPath, EndPoints.home);
    expect(data.place?.name, 'Mira');
    expect(data.featured.single.name, 'Hair');
  });

  test('rejects a successful envelope without a place', () async {
    final client = _Client({'success': true, 'data': <String, dynamic>{}});
    expect(
      HomeRemoteDatasourceImpl(client).getHome(),
      throwsA(isA<UnknownException>()),
    );
  });
}
