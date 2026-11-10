import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/exception_handler.dart';
import 'package:booking_app/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:booking_app/features/categories/domain/entities/category.dart';
import 'package:booking_app/features/categories/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<Category>>> getCategories() =>
      guard(() async => (await _remote.getCategories()).data);
}
