import 'home_data_model.dart';

class HomeModel {
  const HomeModel({required this.success, required this.message, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String? ?? '',
    data: json['data'] == null
        ? null
        : HomeDataModel.fromJson(json['data'] as Map<String, dynamic>),
  );

  final bool success;
  final String message;
  final HomeDataModel? data;

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}
