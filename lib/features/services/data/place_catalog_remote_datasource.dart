import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/features/home/data/models/staff_model.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/models/service_model.dart';

class PlaceCatalogRemoteDatasource {
  const PlaceCatalogRemoteDatasource(this._client);
  final DioClient _client;

  Future<ServicePage> getServices([
    ServiceQuery query = const ServiceQuery(),
  ]) async {
    final body = _envelope(
      await _client.get(
        EndPoints.services,
        queryParameters: query.toQueryParameters(),
      ),
    );
    final data = _list(body['data']);
    return ServicePage(
      data.map((e) => ServiceModel.fromJson(_map(e))).toList(),
      PageMeta.fromJson(_map(body['meta'])),
    );
  }

  Future<ServiceDetails> getService(int id) async {
    final body = _envelope(await _client.get(EndPoints.service(id)));
    final data = _map(body['data']);
    return ServiceDetails(
      ServiceModel.fromJson(data),
      rating: data['rating'] == null
          ? null
          : RatingSummary.fromJson(_map(data['rating'])),
      related: _list(data['related']).map(_map).toList(),
    );
  }

  Future<ReviewPage> getServiceReviews(
    int id, {
    int page = 1,
    int perPage = 15,
  }) => _getReviews(EndPoints.serviceReviews(id), page: page, perPage: perPage);

  Future<List<StaffModel>> getStaff() async {
    final body = _envelope(await _client.get(EndPoints.staff));
    return _list(body['data'])
        .map((e) => StaffModel.fromJson(_map(e)))
        .toList();
  }

  Future<StaffDetails> getStaffMember(int id) async {
    final body = _envelope(await _client.get(EndPoints.staffMember(id)));
    final data = _map(body['data']);
    return StaffDetails(
      StaffModel.fromJson(data),
      services: _list(data['services'])
          .map((e) => StaffService.fromJson(_map(e)))
          .toList(),
      serviceIds: _list(data['service_ids']).cast<int>(),
      latestReviews: _list(data['latest_reviews']).map(_map).toList(),
    );
  }

  Future<ReviewPage> getPlaceReviews({int page = 1, int perPage = 15}) =>
      _getReviews(EndPoints.reviews, page: page, perPage: perPage);

  Future<ReviewPage> _getReviews(
    String path, {
    required int page,
    required int perPage,
  }) async {
    final body = _envelope(
      await _client.get(
        path,
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );
    final meta = _map(body['meta']);
    final rawDistribution = meta['distribution'];
    return ReviewPage(
      _list(body['data']).map(_map).toList(),
      PageMeta.fromJson(meta),
      average: (meta['average'] as num?)?.toDouble(),
      distribution: rawDistribution is Map
          ? rawDistribution.map(
              (key, value) => MapEntry(key.toString(), (value as num).toInt()),
            )
          : const {},
    );
  }

  Future<BusyHours> getBusyHours() async {
    final body = _envelope(await _client.get(EndPoints.busyHours));
    return BusyHours.fromJson(_map(body['data']));
  }

  Map<String, dynamic> _envelope(dynamic value) {
    final body = _map(value);
    if (body['success'] != true) {
      throw ServerException(message: body['message'] as String?);
    }
    return body;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const UnknownException(message: 'Invalid API response format');
  }

  List<dynamic> _list(dynamic value) {
    if (value is List) return value;
    throw const UnknownException(message: 'Invalid API list format');
  }
}
