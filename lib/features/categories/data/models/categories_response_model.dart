import 'package:booking_app/features/categories/data/models/category_model.dart';

class CategoriesResponseModel {
  const CategoriesResponseModel({
    required this.success,
    required this.message,
    this.data = const [],
  });

  final bool success;
  final String message;
  final List<CategoryModel> data;

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      CategoriesResponseModel(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        data: (json['data'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList(growable: false),
      );
}
