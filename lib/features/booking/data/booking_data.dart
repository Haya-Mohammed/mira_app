import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const UnknownException(message: 'Invalid booking response');
}

List<dynamic> _list(dynamic value) {
  if (value is List) return value;
  throw const UnknownException(message: 'Invalid booking list');
}

Map<String, dynamic> _envelope(dynamic value) {
  final body = _map(value);
  if (body['success'] != true) {
    throw ServerException(message: body['message'] as String?);
  }
  return body;
}

class AvailabilityDay {
  AvailabilityDay.fromJson(Map<String, dynamic> json)
    : date = json['date'] as String,
      label = json['label'] as String? ?? '',
      open = json['open'] == true,
      slotsCount = json['slots_count'] as int? ?? 0;

  final String date;
  final String label;
  final bool open;
  final int slotsCount;
}

class AvailabilitySlot {
  AvailabilitySlot.fromJson(Map<String, dynamic> json)
    : time = json['time'] as String,
      startsAt = json['starts_at'] as String,
      seatsLeft = json['seats_left'] as int? ?? 0,
      staff = _list(json['staff'])
          .map((e) => SlotStaff.fromJson(_map(e)))
          .toList();

  final String time;
  final String startsAt;
  final int seatsLeft;
  final List<SlotStaff> staff;
}

class SlotStaff {
  SlotStaff.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String? ?? '';

  final int id;
  final String name;
}

class BookingRecord {
  BookingRecord.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      number = json['number'] as String? ?? '',
      code = json['code'] as String? ?? '',
      status = json['status'] as String? ?? '',
      statusLabel = json['status_label'] as String? ?? '',
      serviceName = json['service_name'] as String? ?? '',
      serviceId = json['service_id'] as int? ?? 0,
      staffName = json['staff_name'] as String?,
      date = json['date'] as String? ?? '',
      dayLabel = json['day_label'] as String? ?? '',
      time = json['time'] as String? ?? '',
      startsAt = json['starts_at'] as String? ?? '',
      total = (json['total'] as num?)?.toDouble(),
      currencySymbol = json['currency_symbol'] as String? ?? '',
      canCancel = json['can_cancel'] == true,
      canReschedule = json['can_reschedule'] == true,
      cancelIsLate = json['cancel_is_late'] == true,
      canReview = json['can_review'] == true,
      cancelReason = json['cancel_reason'] as String?,
      paymentMethodLabel = json['payment_method_label'] as String? ?? '',
      timeline = _list(json['timeline'])
          .map((e) => BookingTimeline.fromJson(_map(e)))
          .toList();

  final int id;
  final String number;
  final String code;
  final String status;
  final String statusLabel;
  final String serviceName;
  final int serviceId;
  final String? staffName;
  final String date;
  final String dayLabel;
  final String time;
  final String startsAt;
  final double? total;
  final String currencySymbol;
  final bool canCancel;
  final bool canReschedule;
  final bool cancelIsLate;
  final bool canReview;
  final String? cancelReason;
  final String paymentMethodLabel;
  final List<BookingTimeline> timeline;
}

class BookingTimeline {
  BookingTimeline.fromJson(Map<String, dynamic> json)
    : label = json['label'] as String? ?? '',
      done = json['done'] == true,
      note = json['note'] as String?;

  final String label;
  final bool done;
  final String? note;
}

class BookingPage {
  const BookingPage(this.items, this.page, this.lastPage);
  final List<BookingRecord> items;
  final int page;
  final int lastPage;
}

class BookingRemoteDatasource {
  const BookingRemoteDatasource(this._client);
  final DioClient _client;

  Future<List<AvailabilityDay>> getDays(int serviceId, {int days = 14}) async {
    final body = _envelope(
      await _client.get(
        EndPoints.availabilityDays,
        queryParameters: {'service_id': serviceId, 'days': days},
      ),
    );
    return _list(body['data'])
        .map((e) => AvailabilityDay.fromJson(_map(e)))
        .toList();
  }

  Future<List<AvailabilitySlot>> getSlots(int serviceId, String date) async {
    final body = _envelope(
      await _client.get(
        EndPoints.availabilitySlots,
        queryParameters: {'service_id': serviceId, 'date': date},
      ),
    );
    return _list(body['data'])
        .map((e) => AvailabilitySlot.fromJson(_map(e)))
        .toList();
  }

  Future<Map<String, dynamic>> checkCoupon(String code, int serviceId) async =>
      _envelope(
        await _client.post(
          EndPoints.couponCheck,
          data: {'code': code, 'service_id': serviceId},
        ),
      );

  Future<BookingRecord> create({
    required int serviceId,
    required String startsAt,
    int? staffId,
    String? notes,
    Map<String, dynamic> answers = const {},
    String? couponCode,
  }) async {
    final body = _envelope(
      await _client.post(
        EndPoints.bookings,
        data: {
          'service_id': serviceId,
          'staff_id': staffId,
          'starts_at': startsAt,
          'notes': notes,
          'answers': answers,
          'coupon_code': couponCode,
          'payment_method': 'cash',
        },
      ),
    );
    return BookingRecord.fromJson(_map(body['data']));
  }

  Future<BookingPage> getBookings({
    String scope = 'upcoming',
    int page = 1,
  }) async {
    final body = _envelope(
      await _client.get(
        EndPoints.bookings,
        queryParameters: {'scope': scope, 'page': page},
      ),
    );
    final meta = _map(body['meta']);
    return BookingPage(
      _list(body['data']).map((e) => BookingRecord.fromJson(_map(e))).toList(),
      meta['page'] as int? ?? page,
      meta['last_page'] as int? ?? page,
    );
  }

  Future<BookingRecord> getBooking(int id) async => BookingRecord.fromJson(
    _map(_envelope(await _client.get(EndPoints.booking(id)))['data']),
  );

  Future<BookingRecord> reschedule(
    int id,
    String startsAt, {
    int? staffId,
  }) async => BookingRecord.fromJson(
    _map(
      _envelope(
        await _client.get(
          EndPoints.rescheduleBooking(id),
          queryParameters: {'starts_at': startsAt, 'staff_id': ?staffId},
        ),
      )['data'],
    ),
  );

  Future<BookingRecord> cancel(int id, {String? reason}) async =>
      BookingRecord.fromJson(
        _map(
          _envelope(
            await _client.post(
              EndPoints.cancelBooking(id),
              data: {'reason': reason},
            ),
          )['data'],
        ),
      );

  Future<Map<String, dynamic>> review(
    int id,
    int rating, {
    String? comment,
  }) async => _envelope(
    await _client.post(
      EndPoints.reviewBooking(id),
      data: {'rating': rating, 'comment': comment},
    ),
  );
}
