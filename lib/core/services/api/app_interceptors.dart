import 'dart:async';

import 'package:booking_app/core/services/api/status_code.dart';
import 'package:dio/dio.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();

class AppInterceptors extends Interceptor {
  AppInterceptors({this.accessTokenProvider, this.onUnauthorized});

  static const String skipAuthKey = 'skipAuth';

  final AccessTokenProvider? accessTokenProvider;

  /// Called on 401 only. 403 (forbidden) must never log the user out.
  final void Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = options.extra[skipAuthKey] == true;

    if (!skip && !options.headers.containsKey('Authorization')) {
      try {
        final token = await accessTokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // A storage failure must not block the request.
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final skip = err.requestOptions.extra[skipAuthKey] == true;

    if (!skip && err.response?.statusCode == StatusCode.unauthorized) {
      onUnauthorized?.call();
    }

    handler.next(err);
  }
}
