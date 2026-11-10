import 'package:booking_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}
