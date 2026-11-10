import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:dartz/dartz.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeDataModel>> getHome();
}
