import 'opening_hours_model.dart';
import 'rating_model.dart';

/// Full staff shape, as listed on the home screen.
class StaffModel {
  const StaffModel({
    required this.id,
    required this.name,
    this.title,
    this.bio,
    this.avatar,
    this.initials,
    this.gender,
    this.color,
    this.isActive = false,
    this.sortOrder = 0,
    this.schedule,
    this.usesPlaceHours = false,
    this.hours = const [],
    this.rating,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
    id: json['id'] as int,
    name: json['name'] as String,
    title: json['title'] as String?,
    bio: json['bio'] as String?,
    avatar: json['avatar'] as String?,
    initials: json['initials'] as String?,
    gender: json['gender'] as String?,
    color: json['color'] as String?,
    isActive: json['is_active'] as bool? ?? false,
    sortOrder: json['sort_order'] as int? ?? 0,
    schedule: json['schedule'],
    usesPlaceHours: json['uses_place_hours'] as bool? ?? false,
    hours: (json['hours'] as List? ?? const [])
        .map((e) => OpeningHoursModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    rating: json['rating'] == null
        ? null
        : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
  );

  final int id;
  final String name;
  final String? title;
  final String? bio;
  final String? avatar;
  final String? initials;
  final String? gender;
  final String? color;
  final bool isActive;
  final int sortOrder;

  /// Raw for now: the sample response was null, so the shape is unknown.
  final Object? schedule;
  final bool usesPlaceHours;
  final List<OpeningHoursModel> hours;
  final RatingModel? rating;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'bio': bio,
    'avatar': avatar,
    'initials': initials,
    'gender': gender,
    'color': color,
    'is_active': isActive,
    'sort_order': sortOrder,
    'schedule': schedule,
    'uses_place_hours': usesPlaceHours,
    'hours': hours.map((e) => e.toJson()).toList(),
    'rating': rating?.toJson(),
  };
}
