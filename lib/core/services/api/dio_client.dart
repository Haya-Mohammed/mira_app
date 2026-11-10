import 'dart:convert';

import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/api/status_code.dart';
import 'package:dio/dio.dart';

class DioClient {
  const DioClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.put<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.patch<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapDioException(error), stackTrace);
    }
  }

  AppException _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ConnectionTimeoutException(
        message: error.message,
      ),
      DioExceptionType.connectionError => NetworkException(
        message: error.message,
      ),
      DioExceptionType.badCertificate => BadCertificateException(
        message: error.message,
      ),
      DioExceptionType.cancel => CancelledException(message: error.message),
      DioExceptionType.badResponse => _mapBadResponse(error.response),
      _ => UnknownException(message: error.message),
    };
  }

  AppException _mapBadResponse(Response<dynamic>? response) {
    final code = response?.statusCode;
    final message = _extractErrorMessage(response?.data);

    return switch (code) {
      StatusCode.badRequest => BadRequestException(
        message: message,
        statusCode: code,
      ),
      StatusCode.unauthorized => UnauthorizedException(
        message: message,
        statusCode: code,
      ),
      StatusCode.forbidden => ForbiddenException(
        message: message,
        statusCode: code,
      ),
      StatusCode.notFound => NotFoundException(
        message: message,
        statusCode: code,
      ),
      StatusCode.conflict => ConflictException(
        message: message,
        statusCode: code,
      ),
      StatusCode.unprocessableEntity => ValidationException(
        message: message,
        statusCode: code,
        fieldErrors: _extractFieldErrors(response?.data),
      ),
      StatusCode.tooManyRequests => TooManyRequestsException(
        message: message,
        statusCode: code,
      ),
      StatusCode.requestTimeout => RequestTimeoutException(
        message: message,
        statusCode: code,
      ),
      int c when c >= 500 && c < 600 => ServerException(
        message: message,
        statusCode: c,
      ),
      _ => UnknownException(
        message: message ?? 'Unexpected status code: $code',
        statusCode: code,
      ),
    };
  }

  String? _extractErrorMessage(dynamic data) {
    try {
      final decoded = data is String && data.isNotEmpty
          ? jsonDecode(data)
          : data;
      if (decoded is! Map) return null;

      for (final key in const ['message', 'error', 'title', 'detail']) {
        final value = decoded[key];
        if (value is String && value.isNotEmpty) return value;
      }

      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String && first.isNotEmpty) return first;
      }
    } catch (_) {
      // Fall through: an unparsable body just means no message.
    }
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      final errors = decoded is Map
          ? decoded['errors'] ??
                (decoded['error'] is Map ? decoded['error']['details'] : null)
          : null;
      if (errors is! Map) return const {};
      return {
        for (final entry in errors.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String
          else if (entry.key is String &&
              entry.value is List &&
              (entry.value as List).isNotEmpty)
            entry.key as String: (entry.value as List).first.toString(),
      };
    } catch (_) {
      return const {};
    }
  }
}
