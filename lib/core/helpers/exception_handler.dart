import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is! AppException) {
    return UnexpectedFailure(message: error.toString());
  }

  final m = error.message;
  final c = error.statusCode;

  return switch (error) {
    NetworkException() => NetworkFailure(message: m, statusCode: c),
    ConnectionTimeoutException() => TimeoutFailure(message: m, statusCode: c),
    CancelledException() => CancelledFailure(message: m, statusCode: c),
    BadCertificateException() => CertificateFailure(message: m, statusCode: c),
    UnauthorizedException() => UnauthorizedFailure(message: m, statusCode: c),
    ForbiddenException() => ForbiddenFailure(message: m, statusCode: c),
    NotFoundException() => NotFoundFailure(message: m, statusCode: c),
    BadRequestException() ||
    ConflictException() => ValidationFailure(message: m, statusCode: c),
    ValidationException() => ValidationFailure(
      message: m,
      statusCode: c,
      fieldErrors: error.fieldErrors,
    ),
    TooManyRequestsException() => TooManyRequestsFailure(
      message: m,
      statusCode: c,
    ),
    RequestTimeoutException() => RequestTimeoutFailure(
      message: m,
      statusCode: c,
    ),
    ServerException() => ServerFailure(message: m, statusCode: c),
    CacheException() => CacheFailure(message: m, statusCode: c),
    UnknownException() => UnexpectedFailure(message: m, statusCode: c),
  };
}

/// Use in repository implementations so every method is one line and no error
/// type can leak past the data layer.
Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } catch (e, st) {
    debugPrint('guard: $e\n$st');
    return Left(mapExceptionToFailure(e));
  }
}
