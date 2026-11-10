import 'package:booking_app/features/categories/data/models/category_model.dart';
import 'package:booking_app/features/services/models/service_model.dart';

import 'place_model.dart';
import 'staff_model.dart';

class HomeDataModel {
  const HomeDataModel({
    this.place,
    this.banners = const [],
    this.categories = const [],
    this.featured = const [],
    this.popular = const [],
    this.staff = const [],
    this.latestReviews = const [],
    this.queue,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
    place: json['place'] == null
        ? null
        : PlaceModel.fromJson(json['place'] as Map<String, dynamic>),
    banners: List<dynamic>.from(json['banners'] as List? ?? const []),
    categories: (json['categories'] as List? ?? const [])
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    featured: (json['featured'] as List? ?? const [])
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    popular: (json['popular'] as List? ?? const [])
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    staff: (json['staff'] as List? ?? const [])
        .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    latestReviews: List<dynamic>.from(
      json['latest_reviews'] as List? ?? const [],
    ),
    queue: json['queue'],
  );

  final PlaceModel? place;

  /// Raw for now: the sample response was empty, so the item shape is unknown.
  final List<dynamic> banners;
  final List<CategoryModel> categories;

  final List<ServiceModel> featured;
  final List<ServiceModel> popular;
  final List<StaffModel> staff;

  /// Raw for now: the sample response was empty, so the item shape is unknown.
  final List<dynamic> latestReviews;

  /// Raw for now: the sample response was null, so the shape is unknown.
  final Object? queue;

  Map<String, dynamic> toJson() => {
    'place': place?.toJson(),
    'banners': banners,
    'categories': categories.map((e) => e.toJson()).toList(),
    'featured': featured.map((e) => e.toJson()).toList(),
    'popular': popular.map((e) => e.toJson()).toList(),
    'staff': staff.map((e) => e.toJson()).toList(),
    'latest_reviews': latestReviews,
    'queue': queue,
  };
}
