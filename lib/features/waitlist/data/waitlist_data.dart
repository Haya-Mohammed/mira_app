import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const UnknownException(message: 'Invalid waitlist response');
}

Map<String, dynamic> _envelope(dynamic value) {
  final body = _map(value);
  if (body['success'] != true) {
    throw ServerException(message: body['message'] as String?);
  }
  return body;
}

class WaitlistPerson {
  const WaitlistPerson({required this.id, required this.name});

  factory WaitlistPerson.fromJson(Map<String, dynamic> json) => WaitlistPerson(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
  );

  final int id;
  final String name;
}

class WaitlistEntry {
  WaitlistEntry.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      status = json['status'] as String? ?? '',
      statusLabel = json['status_label'] as String? ?? '',
      date = json['date'] as String? ?? '',
      fromTime = json['from_time'] as String? ?? '',
      toTime = json['to_time'] as String? ?? '',
      notes = json['notes'] as String?,
      service = WaitlistPerson.fromJson(_map(json['service'])),
      staff = json['staff'] == null
          ? null
          : WaitlistPerson.fromJson(_map(json['staff'])),
      offer = json['offer'] == null ? null : _map(json['offer']),
      canClaim = json['can_claim'] == true,
      bookingId = json['booking_id'] as int?,
      createdAt = json['created_at'] as String? ?? '';

  final int id;
  final String status;
  final String statusLabel;
  final String date;
  final String fromTime;
  final String toTime;
  final String? notes;
  final WaitlistPerson service;
  final WaitlistPerson? staff;
  final Map<String, dynamic>? offer;
  final bool canClaim;
  final int? bookingId;
  final String createdAt;
}

class WaitlistPage {
  const WaitlistPage(this.items, this.page, this.lastPage);
  final List<WaitlistEntry> items;
  final int page;
  final int lastPage;
}

class WaitlistRemoteDatasource {
  const WaitlistRemoteDatasource(this._client);
  final DioClient _client;

  Future<WaitlistEntry> create({
    required int serviceId,
    required String date,
    required String fromTime,
    required String toTime,
    int? staffId,
    String? notes,
  }) async => WaitlistEntry.fromJson(
    _map(
      _envelope(
        await _client.post(
          EndPoints.waitlist,
          data: {
            'service_id': serviceId,
            'staff_id': staffId,
            'date': date,
            'from_time': fromTime,
            'to_time': toTime,
            'notes': notes,
          },
        ),
      )['data'],
    ),
  );

  Future<WaitlistPage> list({int page = 1, bool active = true}) async {
    final body = _envelope(
      await _client.get(
        EndPoints.waitlist,
        queryParameters: {'active': active ? 1 : 0, 'page': page},
      ),
    );
    final meta = _map(body['meta']);
    return WaitlistPage(
      (body['data'] as List)
          .map((item) => WaitlistEntry.fromJson(_map(item)))
          .toList(),
      meta['page'] as int? ?? page,
      meta['last_page'] as int? ?? page,
    );
  }

  Future<WaitlistEntry> get(int id) async => WaitlistEntry.fromJson(
    _map(_envelope(await _client.get(EndPoints.waitlistEntry(id)))['data']),
  );

  Future<void> claim(int id) async {
    _envelope(await _client.post(EndPoints.claimWaitlistEntry(id)));
  }

  Future<String?> remove(int id) async =>
      _envelope(await _client.delete(EndPoints.waitlistEntry(id)))['message']
          as String?;
}
