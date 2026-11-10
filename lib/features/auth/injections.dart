import 'package:booking_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:booking_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:get_it/get_it.dart';

void initAuthFeature(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<Login>(() => Login(sl()))
    ..registerLazySingleton<Register>(() => Register(sl()))
    ..registerLazySingleton<RestoreSession>(() => RestoreSession(sl()))
    ..registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()))
    ..registerLazySingleton<SignOut>(() => SignOut(sl()))
    ..registerLazySingleton<UserCubit>(
      () => UserCubit(sl(), sl(), sl(), sl(), sl()),
    );
}
