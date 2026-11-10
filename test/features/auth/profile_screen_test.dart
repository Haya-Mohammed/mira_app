import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/locale/cubit/locale_cubit.dart';
import 'package:booking_app/core/config/locale/storage/locale_storage_service.dart';
import 'package:booking_app/core/config/theme/cubit/theme_cubit.dart';
import 'package:booking_app/core/config/theme/service/theme_storage_service.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:booking_app/features/home/domain/usecases/get_home.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepository implements AuthRepository {
  String? updatedName;
  String? updatedEmail;
  String? updatedPhone;

  AuthUser _user(String name, String phone) => AuthUser(
    id: 1,
    name: name,
    email: 'sara@example.com',
    phone: phone,
    role: 'customer',
    roleLabel: 'Customer',
    initials: 'SA',
    isActive: true,
    createdAt: '',
    reliability: const Reliability(
      score: 92,
      level: 'good',
      label: 'Good',
      completed: 12,
      noShows: 0,
      lateCancellations: 1,
      total: 13,
    ),
  );

  @override
  Future<Either<Failure, AuthUser>> login(
    String email,
    String password,
  ) async => Right(_user('Sara Ahmad', '0599 123 456'));

  @override
  Future<Either<Failure, AuthUser>> updateProfile(
    String name,
    String email,
    String phone,
  ) async {
    updatedName = name;
    updatedEmail = email;
    updatedPhone = phone;
    return Right(_user(name, phone));
  }

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
  Future<Either<Failure, Unit>> signOut() => throw UnimplementedError();
}

class _HomeRepository implements HomeRepository {
  @override
  Future<Either<Failure, HomeDataModel>> getHome() async =>
      const Right(HomeDataModel());
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
  testWidgets('profile edits name and phone while preserving email', (
    tester,
  ) async {
    final repository = _AuthRepository();
    final cubit = UserCubit(
      Login(repository),
      Register(repository),
      RestoreSession(repository),
      UpdateProfile(repository),
      SignOut(repository),
    );
    await cubit.login('sara@example.com', 'password');
    final localeCubit = LocaleCubit(_LocaleStorage());
    final themeCubit = ThemeCubit(_ThemeStorage());
    sl.registerFactory<HomeCubit>(() => HomeCubit(GetHome(_HomeRepository())));
    addTearDown(() async {
      await cubit.close();
      await localeCubit.close();
      await themeCubit.close();
      await sl.reset();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>.value(value: cubit),
          BlocProvider<LocaleCubit>.value(value: localeCubit),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('92 / 100'), findsOneWidget);
    expect(find.text('Sara Ahmad'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language Change'), findsOneWidget);
    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(themeCubit.state, ThemeMode.dark);
    await tester.ensureVisible(find.text('Language Change'));
    await tester.tap(find.text('Language Change'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(localeCubit.state.locale.languageCode, 'ar');
    await tester.scrollUntilVisible(find.byTooltip('Edit profile'), -200);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'Sara Updated');
    await tester.enterText(find.byType(TextFormField).last, '0599 000 000');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(repository.updatedName, 'Sara Updated');
    expect(repository.updatedEmail, 'sara@example.com');
    expect(repository.updatedPhone, '0599 000 000');
    expect(find.text('Sara Updated'), findsOneWidget);

    tester.testTextInput.hide();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Sara Updated'), findsOneWidget);
  });
}
