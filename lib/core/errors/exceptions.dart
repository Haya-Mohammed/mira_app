/// Thrown by the data layer (DioClient, local data sources).
/// Repositories catch these and convert them to a `Failure`.
sealed class AppException implements Exception {
  const AppException({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType(${statusCode ?? '-'}): ${message ?? ''}';
}

// ---- Transport -------------------------------------------------------------

final class NetworkException extends AppException {
  const NetworkException({super.message, super.statusCode});
}

final class ConnectionTimeoutException extends AppException {
  const ConnectionTimeoutException({super.message, super.statusCode});
}

final class CancelledException extends AppException {
  const CancelledException({super.message, super.statusCode});
}

final class BadCertificateException extends AppException {
  const BadCertificateException({super.message, super.statusCode});
}

// ---- HTTP 4xx --------------------------------------------------------------

/// 400.
final class BadRequestException extends AppException {
  const BadRequestException({super.message, super.statusCode});
}

/// 401: not authenticated / session expired.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message, super.statusCode});
}

/// 403: authenticated but not allowed. Must NOT trigger a logout.
final class ForbiddenException extends AppException {
  const ForbiddenException({super.message, super.statusCode});
}

/// 404.
final class NotFoundException extends AppException {
  const NotFoundException({super.message, super.statusCode});
}

/// 408.
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException({super.message, super.statusCode});
}

/// 409.
final class ConflictException extends AppException {
  const ConflictException({super.message, super.statusCode});
}

/// 422.
final class ValidationException extends AppException {
  const ValidationException({
    super.message,
    super.statusCode,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

/// 429.
final class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.message, super.statusCode});
}

// ---- HTTP 5xx / other ------------------------------------------------------

/// Any 5xx response.
final class ServerException extends AppException {
  const ServerException({super.message, super.statusCode});
}

final class CacheException extends AppException {
  const CacheException({super.message, super.statusCode});
}

final class UnknownException extends AppException {
  const UnknownException({super.message, super.statusCode});
}
