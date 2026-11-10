import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/locale/cubit/locale_cubit.dart';
import 'package:booking_app/core/config/locale/storage/locale_storage_service.dart';
import 'package:booking_app/core/config/theme/cubit/theme_cubit.dart';
import 'package:booking_app/core/config/theme/service/theme_storage_service.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/direct/presentation/screens/direct_screen.dart';
import 'package:booking_app/features/direct/data/queue_remote_datasource.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:booking_app/features/home/domain/usecases/get_home.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:booking_app/features/main/presentation/screens/main_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _HomeRepository implements HomeRepository {
  @override
  Future<Either<Failure, HomeDataModel>> getHome() async =>
      const Left(NetworkFailure());
}

class _AuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthUser?>> restoreSession() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, AuthUser>> updateProfile(
    String name,
    String email,
    String phone,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> signOut() => throw UnimplementedError();
}

class _QueueDatasource extends QueueRemoteDatasource {
  _QueueDatasource({this.status}) : super(DioClient(Dio()));

  final QueueStatus? status;

  @override
  Future<QueueStatus> getStatus() async =>
      status ??
      const QueueStatus(
        enabled: false,
        open: true,
        accepting: false,
        date: '2026-10-20',
        nowServing: [],
        waitingCount: 0,
        next: [],
        servedToday: 0,
        averageMinutes: 15,
        counters: 4,
        estimatedWaitMinutes: 4,
        updatedAt: '2026-10-20T13:46:00+00:00',
      );
}

class _LocaleStorage implements LocaleStorageService {
  @override
  String? getLocaleCode() => 'en';
  @override
  Future<void> saveLocaleCode(String localeCode) async {}
}

class _ThemeStorage implements ThemeStorageService {
  @override
  ThemeMode getThemeMode() => ThemeMode.light;
  @override
  Future<void> saveThemeMode(ThemeMode mode) async {}
}

void main() {
  testWidgets('bottom navigation switches to Direct and Profile', (
    tester,
  ) async {
    final auth = _AuthRepository();
    final userCubit = UserCubit(
      Login(auth),
      Register(auth),
      RestoreSession(auth),
      UpdateProfile(auth),
      SignOut(auth),
    );
    final localeCubit = LocaleCubit(_LocaleStorage());
    final themeCubit = ThemeCubit(_ThemeStorage());
    sl.registerFactory<HomeCubit>(() => HomeCubit(GetHome(_HomeRepository())));
    sl.registerLazySingleton<QueueRemoteDatasource>(() => _QueueDatasource());
    addTearDown(() async {
      await userCubit.close();
      await localeCubit.close();
      await themeCubit.close();
      await sl.reset();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>.value(value: userCubit),
          BlocProvider<LocaleCubit>.value(value: localeCubit),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainScreen(),
        ),
      ),
    );

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Direct'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);
    expect(find.byType(DirectScreen), findsNothing);

    await tester.tap(find.byTooltip('Direct'));
    await tester.pumpAndSettle();
    expect(find.byType(DirectScreen), findsOneWidget);
    expect(find.text('Live queue'), findsOneWidget);
    expect(find.text('Queue list'), findsOneWidget);
    expect(
      find.text('No tickets are listed yet. Pull down to refresh.'),
      findsOneWidget,
    );
    expect(
      find.text('Live queue is unavailable at this venue'),
      findsOneWidget,
    );
    expect(find.text('Take a ticket'), findsNothing);

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language Change'), findsOneWidget);
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(themeCubit.state, ThemeMode.dark);

    await tester.tap(find.byTooltip('Direct'));
    await tester.pumpAndSettle();
    expect(find.byType(DirectScreen), findsOneWidget);
  });

  testWidgets('live queue shows serving and waiting tickets from status', (
    tester,
  ) async {
    final auth = _AuthRepository();
    final userCubit = UserCubit(
      Login(auth),
      Register(auth),
      RestoreSession(auth),
      UpdateProfile(auth),
      SignOut(auth),
    );
    sl.registerLazySingleton<QueueRemoteDatasource>(
      () => _QueueDatasource(
        status: const QueueStatus(
          enabled: true,
          open: true,
          accepting: true,
          date: '2026-10-20',
          nowServing: [
            {'number': 'A-12'},
          ],
          waitingCount: 4,
          next: [
            {'ticket_number': 'A-13'},
          ],
          servedToday: 25,
          averageMinutes: 15,
          counters: 1,
          estimatedWaitMinutes: 6,
          updatedAt: '2026-10-20T13:46:00+00:00',
        ),
      ),
    );
    addTearDown(() async {
      await userCubit.close();
      await sl.reset();
    });

    await tester.pumpWidget(
      BlocProvider<UserCubit>.value(
        value: userCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DirectScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A-12'), findsNWidgets(2));
    expect(find.text('A-13'), findsOneWidget);
    expect(find.text('Take a ticket'), findsOneWidget);
    expect(
      find.text('No tickets are listed yet. Pull down to refresh.'),
      findsNothing,
    );
  });
}
