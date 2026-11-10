import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/categories/domain/entities/category.dart';
import 'package:dartz/dartz.dart';

abstract interface class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
}
