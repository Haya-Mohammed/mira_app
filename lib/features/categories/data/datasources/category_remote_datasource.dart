import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/features/categories/data/models/categories_response_model.dart';

abstract interface class CategoryRemoteDatasource {
  Future<CategoriesResponseModel> getCategories();
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  const CategoryRemoteDatasourceImpl(this._client);

  final DioClient _client;

  @override
  Future<CategoriesResponseModel> getCategories() async {
    final body = await _client.get(EndPoints.categories);

    if (body is! Map<String, dynamic>) {
      throw const UnknownException(message: 'Invalid response format');
    }

    final model = CategoriesResponseModel.fromJson(body);
    if (!model.success) {
      throw ServerException(message: model.message);
    }
    return model;
  }
}
