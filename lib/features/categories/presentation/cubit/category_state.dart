import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/categories/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryEmpty extends CategoryState {
  const CategoryEmpty();
}

final class CategoryLoaded extends CategoryState {
  const CategoryLoaded(this.categories);

  final List<Category> categories;

  @override
  List<Object?> get props => [categories];
}

final class CategoryError extends CategoryState {
  const CategoryError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
