import 'package:booking_app/features/booking/models/booking_model.dart';

import 'contact_model.dart';
import 'opening_hours_model.dart';
import 'place_labels_model.dart';
import 'place_theme_model.dart';
import 'place_type_model.dart';
import 'queue_model.dart';
import 'rating_model.dart';

class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.slug,
    this.tagline,
    this.description,
    this.logo,
    this.cover,
    this.type,
    this.labels,
    this.audience,
    this.audienceLabel,
    this.theme,
    this.contact,
    this.openNow = false,
    this.openingHours = const [],
    this.rating,
    this.booking,
    this.queue,
    this.currency,
    this.currencySymbol,
    this.timezone,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    tagline: json['tagline'] as String?,
    description: json['description'] as String?,
    logo: json['logo'] as String?,
    cover: json['cover'] as String?,
    type: json['type'] == null
        ? null
        : PlaceTypeModel.fromJson(json['type'] as Map<String, dynamic>),
    labels: json['labels'] == null
        ? null
        : PlaceLabelsModel.fromJson(json['labels'] as Map<String, dynamic>),
    audience: json['audience'] as String?,
    audienceLabel: json['audience_label'] as String?,
    theme: json['theme'] == null
        ? null
        : PlaceThemeModel.fromJson(json['theme'] as Map<String, dynamic>),
    contact: json['contact'] == null
        ? null
        : ContactModel.fromJson(json['contact'] as Map<String, dynamic>),
    openNow: json['open_now'] as bool? ?? false,
    openingHours: (json['opening_hours'] as List? ?? const [])
        .map((e) => OpeningHoursModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    rating: json['rating'] == null
        ? null
        : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
    booking: json['booking'] == null
        ? null
        : BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
    queue: json['queue'] == null
        ? null
        : QueueModel.fromJson(json['queue'] as Map<String, dynamic>),
    currency: json['currency'] as String?,
    currencySymbol: json['currency_symbol'] as String?,
    timezone: json['timezone'] as String?,
  );

  final int id;
  final String name;
  final String slug;
  final String? tagline;
  final String? description;
  final String? logo;
  final String? cover;
  final PlaceTypeModel? type;
  final PlaceLabelsModel? labels;
  final String? audience;
  final String? audienceLabel;
  final PlaceThemeModel? theme;
  final ContactModel? contact;
  final bool openNow;
  final List<OpeningHoursModel> openingHours;
  final RatingModel? rating;
  final BookingModel? booking;
  final QueueModel? queue;
  final String? currency;
  final String? currencySymbol;
  final String? timezone;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'tagline': tagline,
    'description': description,
    'logo': logo,
    'cover': cover,
    'type': type?.toJson(),
    'labels': labels?.toJson(),
    'audience': audience,
    'audience_label': audienceLabel,
    'theme': theme?.toJson(),
    'contact': contact?.toJson(),
    'open_now': openNow,
    'opening_hours': openingHours.map((e) => e.toJson()).toList(),
    'rating': rating?.toJson(),
    'booking': booking?.toJson(),
    'queue': queue?.toJson(),
    'currency': currency,
    'currency_symbol': currencySymbol,
    'timezone': timezone,
  };
}
