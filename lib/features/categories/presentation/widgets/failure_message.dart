import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:flutter/widgets.dart';

/// Add to your ARB files: `noInternet`, `somethingWentWrong`.
extension FailureMessage on Failure {
  String localized(BuildContext context) => switch (this) {
    NetworkFailure() ||
    TimeoutFailure() ||
    RequestTimeoutFailure() => context.text.noInternet,
    // Server-provided messages are already user-facing (and localized by the API).
    ValidationFailure() ||
    ServerFailure() ||
    NotFoundFailure() ||
    ForbiddenFailure() =>
      (message?.isNotEmpty ?? false)
          ? message!
          : context.text.somethingWentWrong,
    _ => context.text.somethingWentWrong,
  };
}
