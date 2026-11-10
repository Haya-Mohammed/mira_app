import 'package:booking_app/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:booking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:booking_app/features/categories/domain/repositories/category_repository.dart';
import 'package:booking_app/features/categories/domain/usecases/get_categories.dart';
import 'package:booking_app/features/categories/presentation/cubit/category_cubit.dart';
import 'package:get_it/get_it.dart';

void initCategoriesFeature(GetIt sl) {
  sl
    ..registerLazySingleton<CategoryRemoteDatasource>(
      () => CategoryRemoteDatasourceImpl(sl()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl()),
    )
    ..registerLazySingleton<GetCategories>(() => GetCategories(sl()))
    ..registerFactory<CategoryCubit>(() => CategoryCubit(sl()));
}
