import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:flutter/material.dart';

extension AuthFailureMessage on Failure {
  String? fieldError(String field) => this is ValidationFailure
      ? (this as ValidationFailure).fieldErrors[field]
      : null;

  String authMessage(BuildContext context) => switch (this) {
    NetworkFailure() ||
    TimeoutFailure() ||
    RequestTimeoutFailure() => context.text.errorNetwork,
    UnauthorizedFailure() => context.text.invalidCredentials,
    TooManyRequestsFailure() => context.text.errorTooManyRequests,
    ForbiddenFailure() => context.text.errorForbidden,
    ValidationFailure() =>
      message?.isNotEmpty == true ? message! : context.text.errorValidation,
    ServerFailure() => context.text.errorServer,
    _ => context.text.errorUnexpected,
  };
}
