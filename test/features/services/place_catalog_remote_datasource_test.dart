import 'dart:convert';
import 'dart:io';

import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late PlaceCatalogRemoteDatasource source;
  final requests = <Uri>[];

  setUp(() async {
    requests.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add(request.uri);
      final path = request.uri.path;
      final payload = switch (path) {
        '/api/v1/places/mira/services' =>
          request.uri.queryParameters.containsKey('category_id')
              ? {
                  'data': [],
                  'meta': {
                    'page': 1,
                    'per_page': 15,
                    'total': 0,
                    'last_page': 1,
                  },
                }
              : request.uri.queryParameters['q'] == 'paged'
              ? {
                  'data': [
                    if (request.uri.queryParameters['page'] == '2')
                      {..._service, 'id': 41}
                    else
                      _service,
                  ],
                  'meta': {
                    'page': request.uri.queryParameters['page'] == '2' ? 2 : 1,
                    'per_page': 15,
                    'total': 2,
                    'last_page': 2,
                  },
                }
              : {
                  'data': [_service],
                  'meta': {
                    'page': 1,
                    'per_page': 15,
                    'total': 1,
                    'last_page': 1,
                  },
                },
        '/api/v1/places/mira/services/40' => {
          'data': {
            ..._service,
            'rating': {'average': 0, 'count': 0},
            'related': [],
          },
        },
        '/api/v1/places/mira/services/40/reviews' => {
          'data': [],
          'meta': {'page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
        },
        '/api/v1/places/mira/staff' => {
          'data': [_staff],
        },
        '/api/v1/places/mira/staff/27' => {
          'data': {
            ..._staff,
            'services': [
              {
                'id': 40,
                'name': 'Makeup',
                'duration_minutes': 60,
                'final_price': 150,
              },
            ],
            'service_ids': [40],
            'latest_reviews': [],
          },
        },
        '/api/v1/places/mira/reviews' => {
          'data': [],
          'meta': {
            'page': 1,
            'per_page': 15,
            'total': 0,
            'last_page': 1,
            'average': 0,
            'distribution': {'5': 0},
          },
        },
        '/api/v1/places/mira/insights/busy-hours' => {
          'data': {
            'from_hour': 9,
            'to_hour': 10,
            'grid': [
              {
                'day': 'sat',
                'label': 'Saturday',
                'hours': [
                  {'hour': 9, 'open': true, 'level': 0},
                  {'hour': 10, 'open': false, 'level': null},
                ],
              },
            ],
            'best_times': [
              {
                'day': 'sat',
                'label': 'Saturday',
                'hour': 9,
                'time': '09:00',
                'level': 0,
              },
            ],
            'now': {'open': false, 'level': null, 'label': 'Closed'},
          },
        },
        _ => throw StateError('Unexpected endpoint: $path'),
      };
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'success': true, 'message': 'OK', ...payload}),
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
    source = PlaceCatalogRemoteDatasource(DioClient(dio));
  });

  tearDown(() async => server.close(force: true));

  test('category and search queries use typed URL parameters', () async {
    final empty = await source.getServices(const ServiceQuery(categoryId: 8));
    expect(empty.items, isEmpty);
    expect(empty.meta.hasNextPage, isFalse);
    expect(requests.single.queryParameters, {
      'category_id': '8',
      'page': '1',
      'per_page': '15',
    });

    final results = await source.getServices(
      const ServiceQuery(
        q: '',
        staffId: 27,
        maxDuration: 60,
        sort: 'price',
        order: 'asc',
      ),
    );
    expect(results.items.single.name, 'Makeup');
    expect(results.items.single.finalPrice, 150);
    expect(requests.last.queryParameters, {
      'page': '1',
      'per_page': '15',
      'q': '',
      'staff_id': '27',
      'max_duration': '60',
      'sort': 'price',
      'order': 'asc',
    });
  });

  test('service detail and review endpoints parse their envelopes', () async {
    final detail = await source.getService(40);
    final reviews = await source.getServiceReviews(40);
    expect(detail.service.id, 40);
    expect(detail.rating?.count, 0);
    expect(reviews.items, isEmpty);
    expect(requests.map((request) => request.path), [
      '/api/v1/places/mira/services/40',
      '/api/v1/places/mira/services/40/reviews',
    ]);
  });

  test(
    'staff, place reviews and busy hours retain the supplied facts',
    () async {
      final staff = await source.getStaff();
      final detail = await source.getStaffMember(27);
      final reviews = await source.getPlaceReviews();
      final busy = await source.getBusyHours();
      expect(staff.single.name, 'Siham');
      expect(detail.services.single.id, 40);
      expect(detail.serviceIds, [40]);
      expect(reviews.average, 0);
      expect(reviews.distribution['5'], 0);
      expect(busy.grid.single.hours.first.open, isTrue);
      expect(busy.grid.single.hours.last.level, isNull);
      expect(busy.bestTimes.single.time, '09:00');
      expect(busy.now?.label, 'Closed');
    },
  );

  test('catalog loads the next page over HTTP and keeps both items', () async {
    final cubit = ServicesCubit(source, query: const ServiceQuery(q: 'paged'));
    await cubit.load();
    expect(cubit.state.meta?.hasNextPage, isTrue);
    await cubit.loadMore();
    expect(cubit.state.items.map((item) => item.id), [40, 41]);
    expect(cubit.state.meta?.hasNextPage, isFalse);
    expect(requests.last.queryParameters['page'], '2');
    await cubit.close();
  });
}

const _service = <String, dynamic>{
  'id': 40,
  'name': 'Makeup',
  'slug': 'makeup',
  'duration_minutes': 60,
  'final_price': 150,
  'is_active': true,
  'staff': [],
};

const _staff = <String, dynamic>{
  'id': 27,
  'name': 'Siham',
  'title': 'Makeup artist',
  'is_active': true,
  'hours': [],
  'rating': {'average': 0, 'count': 0},
};
