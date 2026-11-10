import 'package:booking_app/features/categories/domain/entities/category.dart';

/// A [Category] that knows how to parse itself. Being a subtype of the entity,
/// it can be returned from the repository as-is (no mapping step needed).
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.icon,
    super.image,
    super.sortOrder,
    super.isActive,
    super.servicesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String?,
    image: json['image'] as String?,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    isActive: json['is_active'] as bool? ?? false,
    servicesCount: (json['services_count'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'image': image,
    'sort_order': sortOrder,
    'is_active': isActive,
    'services_count': servicesCount,
  };
}
