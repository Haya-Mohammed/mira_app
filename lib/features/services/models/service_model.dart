import 'package:booking_app/features/categories/data/models/category_model.dart';

import '../../home/data/models/staff_summary_model.dart';
import 'service_image_model.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.durationMinutes,
    this.durationLabel,
    this.bufferMinutes,
    this.price,
    this.salePrice,
    this.finalPrice,
    this.discountPercent,
    this.capacity,
    this.isGroup = false,
    this.image,
    this.thumb,
    this.images = const [],
    this.attributes = const {},
    this.attributesDisplay = const [],
    this.isActive = false,
    this.isFeatured = false,
    this.bookingsCount = 0,
    this.sortOrder = 0,
    this.categoryId,
    this.category,
    this.staff = const [],
    this.staffIds = const [],
    this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Laravel serializes an empty array as `[]`, not `{}`, so guard the cast.
    final rawAttributes = json['attributes'];

    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      durationLabel: json['duration_label'] as String?,
      bufferMinutes: json['buffer_minutes'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      isGroup: json['is_group'] as bool? ?? false,
      image: json['image'] as String?,
      thumb: json['thumb'] as String?,
      images: (json['images'] as List? ?? const [])
          .map((e) => ServiceImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: rawAttributes is Map
          ? Map<String, dynamic>.from(rawAttributes)
          : const {},
      attributesDisplay: List<dynamic>.from(
        json['attributes_display'] as List? ?? const [],
      ),
      isActive: json['is_active'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      bookingsCount: json['bookings_count'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
      categoryId: json['category_id'] as int?,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      staff: (json['staff'] as List? ?? const [])
          .map((e) => StaffSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      staffIds: List<int>.from(json['staff_ids'] as List? ?? const []),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? durationMinutes;
  final String? durationLabel;
  final int? bufferMinutes;
  final double? price;
  final double? salePrice;
  final double? finalPrice;
  final double? discountPercent;
  final int? capacity;
  final bool isGroup;
  final String? image;
  final String? thumb;
  final List<ServiceImageModel> images;

  /// Free-form key/value data; the keys vary per service.
  final Map<String, dynamic> attributes;

  /// Raw for now: the sample response was empty, so the item shape is unknown.
  final List<dynamic> attributesDisplay;
  final bool isActive;
  final bool isFeatured;
  final int bookingsCount;
  final int sortOrder;
  final int? categoryId;
  final CategoryModel? category;
  final List<StaffSummaryModel> staff;
  final List<int> staffIds;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'duration_minutes': durationMinutes,
    'duration_label': durationLabel,
    'buffer_minutes': bufferMinutes,
    'price': price,
    'sale_price': salePrice,
    'final_price': finalPrice,
    'discount_percent': discountPercent,
    'capacity': capacity,
    'is_group': isGroup,
    'image': image,
    'thumb': thumb,
    'images': images.map((e) => e.toJson()).toList(),
    'attributes': attributes,
    'attributes_display': attributesDisplay,
    'is_active': isActive,
    'is_featured': isFeatured,
    'bookings_count': bookingsCount,
    'sort_order': sortOrder,
    'category_id': categoryId,
    'category': category?.toJson(),
    'staff': staff.map((e) => e.toJson()).toList(),
    'staff_ids': staffIds,
    'created_at': createdAt?.toIso8601String(),
  };
}
