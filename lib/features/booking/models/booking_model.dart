import 'package:booking_app/features/home/data/models/intake_field_model.dart';

class BookingModel {
  const BookingModel({
    this.windowDays,
    this.minNoticeMinutes,
    this.cancelBeforeHours,
    this.maxActiveBookings,
    this.autoConfirm = false,
    this.intakeFields = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    windowDays: json['window_days'] as int?,
    minNoticeMinutes: json['min_notice_minutes'] as int?,
    cancelBeforeHours: json['cancel_before_hours'] as int?,
    maxActiveBookings: json['max_active_bookings'] as int?,
    autoConfirm: json['auto_confirm'] as bool? ?? false,
    intakeFields: (json['intake_fields'] as List? ?? const [])
        .map((e) => IntakeFieldModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int? windowDays;
  final int? minNoticeMinutes;
  final int? cancelBeforeHours;
  final int? maxActiveBookings;
  final bool autoConfirm;
  final List<IntakeFieldModel> intakeFields;

  Map<String, dynamic> toJson() => {
    'window_days': windowDays,
    'min_notice_minutes': minNoticeMinutes,
    'cancel_before_hours': cancelBeforeHours,
    'max_active_bookings': maxActiveBookings,
    'auto_confirm': autoConfirm,
    'intake_fields': intakeFields.map((e) => e.toJson()).toList(),
  };
}
