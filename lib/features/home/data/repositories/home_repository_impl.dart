import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/exception_handler.dart';
import 'package:booking_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remote);

  final HomeRemoteDatasource _remote;

  @override
  Future<Either<Failure, HomeDataModel>> getHome() =>
      guard(() => _remote.getHome());
}
