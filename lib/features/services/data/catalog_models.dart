import 'package:booking_app/features/home/data/models/staff_model.dart';
import 'package:booking_app/features/services/models/service_model.dart';

/// Query values are sent as URL parameters, not HTTP headers.
class ServiceQuery {
  const ServiceQuery({
    this.categoryId,
    this.page = 1,
    this.perPage = 15,
    this.q,
    this.staffId,
    this.maxDuration,
    this.sort,
    this.order,
  });

  final int? categoryId;
  final int page;
  final int perPage;
  final String? q;
  final int? staffId;
  final int? maxDuration;
  final String? sort;
  final String? order;

  Map<String, dynamic> toQueryParameters() => {
    if (categoryId != null) 'category_id': categoryId,
    'page': page,
    'per_page': perPage,
    if (q != null) 'q': q!.trim(),
    if (staffId != null) 'staff_id': staffId,
    if (maxDuration != null) 'max_duration': maxDuration,
    if (sort != null) 'sort': sort,
    if (order != null) 'order': order,
  };
}

class PageMeta {
  const PageMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
    page: json['page'] as int? ?? 1,
    perPage: json['per_page'] as int? ?? 15,
    total: json['total'] as int? ?? 0,
    lastPage: json['last_page'] as int? ?? 1,
  );

  final int page;
  final int perPage;
  final int total;
  final int lastPage;
  bool get hasNextPage => page < lastPage;
}

class ServicePage {
  const ServicePage(this.items, this.meta);
  final List<ServiceModel> items;
  final PageMeta meta;
}

class ReviewPage {
  const ReviewPage(
    this.items,
    this.meta, {
    this.average,
    this.distribution = const {},
  });
  // No non-empty review example has been provided. Preserve unknown fields.
  final List<Map<String, dynamic>> items;
  final PageMeta meta;
  final double? average;
  final Map<String, int> distribution;
}

class ServiceDetails {
  const ServiceDetails(this.service, {this.rating, this.related = const []});
  final ServiceModel service;
  final RatingSummary? rating;

  /// The example was empty; keep future related item shapes intact.
  final List<Map<String, dynamic>> related;
}

class RatingSummary {
  const RatingSummary(this.average, this.count);
  factory RatingSummary.fromJson(Map<String, dynamic> json) => RatingSummary(
    (json['average'] as num?)?.toDouble() ?? 0,
    json['count'] as int? ?? 0,
  );
  final double average;
  final int count;
}

class StaffDetails {
  const StaffDetails(
    this.staff, {
    this.services = const [],
    this.serviceIds = const [],
    this.latestReviews = const [],
  });
  final StaffModel staff;
  final List<StaffService> services;
  final List<int> serviceIds;
  final List<Map<String, dynamic>> latestReviews;
}

class StaffService {
  const StaffService({
    required this.id,
    required this.name,
    this.durationMinutes,
    this.finalPrice,
  });
  factory StaffService.fromJson(Map<String, dynamic> json) => StaffService(
    id: json['id'] as int,
    name: json['name'] as String,
    durationMinutes: json['duration_minutes'] as int?,
    finalPrice: (json['final_price'] as num?)?.toDouble(),
  );
  final int id;
  final String name;
  final int? durationMinutes;
  final double? finalPrice;
}

class BusyHours {
  const BusyHours({
    required this.fromHour,
    required this.toHour,
    required this.grid,
    required this.bestTimes,
    this.now,
  });
  final int fromHour;
  final int toHour;
  final List<BusyDay> grid;
  final List<BestTime> bestTimes;
  final BusyNow? now;

  factory BusyHours.fromJson(Map<String, dynamic> json) => BusyHours(
    fromHour: json['from_hour'] as int? ?? 0,
    toHour: json['to_hour'] as int? ?? 0,
    grid: (json['grid'] as List? ?? const [])
        .map((e) => BusyDay.fromJson(e as Map<String, dynamic>))
        .toList(),
    bestTimes: (json['best_times'] as List? ?? const [])
        .map((e) => BestTime.fromJson(e as Map<String, dynamic>))
        .toList(),
    now: json['now'] is Map<String, dynamic>
        ? BusyNow.fromJson(json['now'] as Map<String, dynamic>)
        : null,
  );
}

class BusyDay {
  const BusyDay(this.day, this.label, this.hours);
  factory BusyDay.fromJson(Map<String, dynamic> json) => BusyDay(
    json['day'] as String? ?? '',
    json['label'] as String? ?? '',
    (json['hours'] as List? ?? const [])
        .map((e) => BusyHour.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  final String day;
  final String label;
  final List<BusyHour> hours;
}

class BusyHour {
  const BusyHour(this.hour, this.open, this.level);
  factory BusyHour.fromJson(Map<String, dynamic> json) => BusyHour(
    json['hour'] as int? ?? 0,
    json['open'] as bool? ?? false,
    (json['level'] as num?)?.toDouble(),
  );
  final int hour;
  final bool open;

  /// Historical busyness indicator. It is not appointment availability.
  final double? level;
}

class BestTime {
  const BestTime(this.day, this.label, this.hour, this.time, this.level);
  factory BestTime.fromJson(Map<String, dynamic> json) => BestTime(
    json['day'] as String? ?? '',
    json['label'] as String? ?? '',
    json['hour'] as int? ?? 0,
    json['time'] as String? ?? '',
    (json['level'] as num?)?.toDouble() ?? 0,
  );
  final String day;
  final String label;
  final int hour;
  final String time;
  final double level;
}

class BusyNow {
  const BusyNow(this.open, this.level, this.label);
  factory BusyNow.fromJson(Map<String, dynamic> json) => BusyNow(
    json['open'] as bool? ?? false,
    (json['level'] as num?)?.toDouble(),
    json['label'] as String? ?? '',
  );
  final bool open;
  final double? level;
  final String label;
}
