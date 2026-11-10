import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';

class NotificationsPage {
  const NotificationsPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.unread,
  });

  final List<Map<String, dynamic>> items;
  final int page;
  final int perPage;
  final int total;
  final int lastPage;
  final int unread;
}

class NotificationsRemoteDatasource {
  const NotificationsRemoteDatasource(this._client);

  final DioClient _client;

  Future<NotificationsPage> getNotifications({int page = 1}) async {
    final body = _envelope(
      await _client.get(
        EndPoints.notifications,
        queryParameters: {'page': page},
      ),
    );
    final data = body['data'];
    final meta = body['meta'];
    if (data is! List || meta is! Map) {
      throw const UnknownException(message: 'Invalid notifications response');
    }
    return NotificationsPage(
      items: data.map((item) {
        if (item is! Map) {
          throw const UnknownException(message: 'Invalid notification');
        }
        return Map<String, dynamic>.from(item);
      }).toList(),
      page: _number(meta['page']),
      perPage: _number(meta['per_page']),
      total: _number(meta['total']),
      lastPage: _number(meta['last_page']),
      unread: _number(meta['unread']),
    );
  }

  Future<int> readAll() async {
    final body = _envelope(await _client.post(EndPoints.readAllNotifications));
    final data = body['data'];
    if (data is! Map) {
      throw const UnknownException(message: 'Invalid read-all response');
    }
    return _number(data['unread']);
  }

  Map<String, dynamic> _envelope(dynamic value) {
    if (value is! Map) {
      throw const UnknownException(message: 'Invalid notifications response');
    }
    final body = Map<String, dynamic>.from(value);
    if (body['success'] != true) {
      throw ServerException(message: body['message'] as String?);
    }
    return body;
  }

  int _number(dynamic value) {
    if (value is num) return value.toInt();
    throw const UnknownException(message: 'Invalid notifications metadata');
  }
}
