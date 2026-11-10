import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/usecase.dart';
import 'package:booking_app/features/categories/domain/entities/category.dart';
import 'package:booking_app/features/categories/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategories implements UseCase<List<Category>, NoParams> {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, List<Category>>> call([
    NoParams params = const NoParams(),
  ]) async {
    final result = await _repository.getCategories();
    return result.map(
      (all) =>
          all.where((c) => c.isActive).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }
}
