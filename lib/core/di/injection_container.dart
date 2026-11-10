import 'package:booking_app/core/config/locale/cubit/locale_cubit.dart';
import 'package:booking_app/core/config/locale/storage/locale_storage_service.dart';
import 'package:booking_app/core/config/theme/cubit/theme_cubit.dart';
import 'package:booking_app/core/config/theme/service/theme_storage_service.dart';
import 'package:booking_app/core/services/api/app_interceptors.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/core/services/api/end_points.dart';
import 'package:booking_app/core/services/network/network_info.dart';
import 'package:booking_app/core/services/storage/secure_storage_service.dart';
import 'package:booking_app/core/services/storage/shared_preferences_service.dart';
import 'package:booking_app/core/services/storage/storage_keys.dart';
import 'package:booking_app/features/categories/injections.dart';
import 'package:booking_app/features/auth/injections.dart';
import 'package:booking_app/features/home/injections.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:booking_app/features/direct/data/queue_remote_datasource.dart';
import 'package:booking_app/features/notifications/data/notifications_remote_datasource.dart';
import 'package:booking_app/features/waitlist/data/waitlist_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initStorage();
  _initNetwork();
  _initLocale();
  _initTheme();

  /// Features
  initHomeFeature(sl);
  initCategoriesFeature(sl);
  initAuthFeature(sl);
  sl.registerLazySingleton<PlaceCatalogRemoteDatasource>(
    () => PlaceCatalogRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<BookingRemoteDatasource>(
    () => BookingRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<WaitlistRemoteDatasource>(
    () => WaitlistRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<QueueRemoteDatasource>(
    () => QueueRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDatasource>(
    () => NotificationsRemoteDatasource(sl()),
  );
}

Future<void> _initStorage() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    ..registerLazySingleton<SharedPreferencesService>(
      () => SharedPreferencesService(sl()),
    )
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(sl()),
    );
}

void _initNetwork() {
  sl
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<AppInterceptors>(
      () => AppInterceptors(
        accessTokenProvider: () =>
            sl<SecureStorageService>().read(StorageKeys.accessToken),
        // onUnauthorized: () => sl<AuthCubit>().sessionExpired(),
      ),
    )
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: EndPoints.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 60),
          headers: const {'Accept': 'application/json'},
        ),
      );

      dio.interceptors.addAll([
        if (kDebugMode)
          LogInterceptor(
            requestBody: false,
            responseBody: false,
            logPrint: (object) => debugPrint(object.toString()),
          ),
        sl<AppInterceptors>(),
      ]);

      return dio;
    })
    ..registerLazySingleton<DioClient>(() => DioClient(sl()));
}

void _initLocale() {
  sl
    ..registerLazySingleton<LocaleStorageService>(
      () => LocaleStorageServiceImpl(sl()),
    )
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl()));
}

void _initTheme() {
  sl
    ..registerLazySingleton<ThemeStorageService>(
      () => ThemeStorageServiceImpl(sl()),
    )
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));
}
