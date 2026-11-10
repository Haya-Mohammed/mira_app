import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/usecase.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetHome implements UseCase<HomeDataModel, NoParams> {
  const GetHome(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeDataModel>> call([
    NoParams params = const NoParams(),
  ]) => _repository.getHome();
}
