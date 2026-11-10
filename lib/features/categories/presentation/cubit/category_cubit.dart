import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/categories/domain/usecases/get_categories.dart';
import 'package:booking_app/features/categories/presentation/cubit/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._getCategories) : super(const CategoryInitial());

  final GetCategories _getCategories;

  /// First load / retry: shows the loading state.
  Future<void> fetchCategories() async {
    emit(const CategoryLoading());
    await _load();
  }

  /// Pull-to-refresh: keeps the current content on screen while loading.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    final result = await _getCategories();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is CancelledFailure) return;
        emit(CategoryError(failure));
      },
      (categories) => emit(
        categories.isEmpty ? const CategoryEmpty() : CategoryLoaded(categories),
      ),
    );
  }
}
