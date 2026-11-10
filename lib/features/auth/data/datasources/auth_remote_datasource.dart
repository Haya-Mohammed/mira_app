import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/app_interceptors.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/features/auth/data/models/auth_user_model.dart';
import 'package:dio/dio.dart';

class AuthSessionResponse {
  const AuthSessionResponse(this.token, this.user);
  final String token;
  final AuthUserModel user;
}

abstract interface class AuthRemoteDatasource {
  Future<AuthSessionResponse> login(String email, String password);
  Future<AuthSessionResponse> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  );
  Future<AuthUserModel> me();
  Future<AuthUserModel> updateProfile(String name, String email, String phone);
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this._client);
  final DioClient _client;

  static final _publicOptions = Options(
    extra: {AppInterceptors.skipAuthKey: true},
  );

  @override
  Future<AuthSessionResponse> login(String email, String password) async =>
      _session(
        await _client.post(
          EndPoints.login,
          options: _publicOptions,
          data: {
            'email': email,
            'password': password,
            'device_name': 'booking_app',
          },
        ),
      );

  @override
  Future<AuthSessionResponse> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) async => _session(
    await _client.post(
      EndPoints.register,
      options: _publicOptions,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmation,
        'device_name': 'booking_app',
      },
    ),
  );

  @override
  Future<AuthUserModel> me() async => _user(await _client.get(EndPoints.me));

  @override
  Future<AuthUserModel> updateProfile(
    String name,
    String email,
    String phone,
  ) async => _user(
    await _client.put(
      EndPoints.profile,
      data: {'name': name, 'email': email, 'phone': phone},
    ),
  );

  @override
  Future<void> logout() async {
    final body = await _client.post(EndPoints.logout);
    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw ServerException(
        message: body is Map
            ? body['message'] as String?
            : 'Invalid logout response',
      );
    }
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const UnknownException(message: 'Invalid auth response');
    }
    if (body['success'] != true) {
      throw ServerException(message: body['message'] as String?);
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnknownException(message: 'Missing auth data');
    }
    return data;
  }

  AuthUserModel _user(dynamic body) => AuthUserModel.fromJson(_data(body));

  AuthSessionResponse _session(dynamic body) {
    final data = _data(body);
    final token = data['token'];
    final user = data['user'];
    if (token is! String || token.isEmpty || user is! Map<String, dynamic>) {
      throw const UnknownException(message: 'Invalid auth session');
    }
    return AuthSessionResponse(token, AuthUserModel.fromJson(user));
  }
}
