import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const UnknownException(message: 'Invalid queue response');
}

dynamic _data(dynamic value) {
  final body = _map(value);
  if (body['success'] != true) {
    throw ServerException(message: body['message'] as String?);
  }
  return body['data'];
}

class QueueStatus {
  const QueueStatus({
    required this.enabled,
    required this.open,
    required this.accepting,
    required this.date,
    required this.nowServing,
    required this.waitingCount,
    required this.next,
    required this.servedToday,
    required this.averageMinutes,
    required this.counters,
    required this.estimatedWaitMinutes,
    required this.updatedAt,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) => QueueStatus(
    enabled: json['enabled'] == true,
    open: json['open'] == true,
    accepting: json['accepting'] == true,
    date: json['date'] as String? ?? '',
    nowServing: (json['now_serving'] as List? ?? const []).toList(),
    waitingCount: (json['waiting_count'] as num?)?.toInt() ?? 0,
    next: (json['next'] as List? ?? const []).toList(),
    servedToday: (json['served_today'] as num?)?.toInt() ?? 0,
    averageMinutes: (json['average_minutes'] as num?)?.toInt(),
    counters: (json['counters'] as num?)?.toInt() ?? 0,
    estimatedWaitMinutes: (json['estimated_wait_minutes'] as num?)?.toInt(),
    updatedAt: json['updated_at'] as String? ?? '',
  );

  final bool enabled;
  final bool open;
  final bool accepting;
  final String date;
  final List<dynamic> nowServing;
  final int waitingCount;
  final List<dynamic> next;
  final int servedToday;
  final int? averageMinutes;
  final int counters;
  final int? estimatedWaitMinutes;
  final String updatedAt;
}

class QueueTicket {
  const QueueTicket({
    required this.id,
    this.number,
    this.status,
    this.position,
  });

  factory QueueTicket.fromJson(Map<String, dynamic> json) => QueueTicket(
    id: (json['id'] as num).toInt(),
    number: (json['number'] ?? json['ticket_number'])?.toString(),
    status: (json['status_label'] ?? json['status'])?.toString(),
    position: (json['position'] as num?)?.toInt(),
  );

  final int id;
  final String? number;
  final String? status;
  final int? position;
}

class QueueRemoteDatasource {
  const QueueRemoteDatasource(this._client);
  final DioClient _client;

  Future<QueueStatus> getStatus() async =>
      QueueStatus.fromJson(_map(_data(await _client.get(EndPoints.queue))));

  Future<QueueTicket?> getMyTicket() async {
    final data = _data(await _client.get(EndPoints.myQueueTicket));
    return data == null ? null : QueueTicket.fromJson(_map(data));
  }

  Future<QueueTicket> createTicket({int? serviceId}) async =>
      QueueTicket.fromJson(
        _map(
          _data(
            await _client.post(
              EndPoints.queueTickets,
              data: {'service_id': serviceId},
            ),
          ),
        ),
      );

  Future<void> cancelTicket(int id) async {
    _data(await _client.post(EndPoints.cancelQueueTicket(id)));
  }
}
