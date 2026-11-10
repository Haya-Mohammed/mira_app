import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/data/models/home_model.dart';

abstract interface class HomeRemoteDatasource {
  Future<HomeDataModel> getHome();
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  const HomeRemoteDatasourceImpl(this._client);

  final DioClient _client;

  @override
  Future<HomeDataModel> getHome() async {
    final body = await _client.get(EndPoints.home);
    if (body is! Map<String, dynamic>) {
      throw const UnknownException(message: 'Invalid home response format');
    }
    final response = HomeModel.fromJson(body);
    if (!response.success) {
      throw ServerException(message: response.message);
    }
    if (response.data == null || response.data!.place == null) {
      throw const UnknownException(message: 'Home response has no place');
    }
    return response.data!;
  }
}
