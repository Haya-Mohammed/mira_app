import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.statusCode});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message, super.statusCode});
}

final class CancelledFailure extends Failure {
  const CancelledFailure({super.message, super.statusCode});
}

final class CertificateFailure extends Failure {
  const CertificateFailure({super.message, super.statusCode});
}

/// 401: route the user to login / refresh the session.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.statusCode});
}

/// 403: show "not allowed".
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.statusCode});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.statusCode});
}

/// 400 / 409 / 408 / 422.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    super.statusCode,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({super.message, super.statusCode});
}

final class RequestTimeoutFailure extends Failure {
  const RequestTimeoutFailure({super.message, super.statusCode});
}

final class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode});
}

final class CacheFailure extends Failure {
  const CacheFailure({super.message, super.statusCode});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.statusCode});
}
