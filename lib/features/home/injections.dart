import 'package:booking_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:booking_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:booking_app/features/home/domain/usecases/get_home.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:get_it/get_it.dart';

void initHomeFeature(GetIt sl) {
  sl
    ..registerLazySingleton<HomeRemoteDatasource>(
      () => HomeRemoteDatasourceImpl(sl()),
    )
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()))
    ..registerLazySingleton<GetHome>(() => GetHome(sl()))
    ..registerFactory<HomeCubit>(() => HomeCubit(sl()));
}
