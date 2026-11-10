import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/widgets/app_logo.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/domain/repositories/home_repository.dart';
import 'package:booking_app/features/home/domain/usecases/get_home.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:booking_app/features/home/presentation/cubit/home_state.dart';
import 'package:booking_app/features/home/presentation/screens/home_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _HomeRepository implements HomeRepository {
  _HomeRepository(this.data);
  final HomeDataModel data;

  @override
  Future<Either<Failure, HomeDataModel>> getHome() async => Right(data);
}

class _UnusedAuthRepository implements AuthRepository {
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

class _RetryRepository implements HomeRepository {
  _RetryRepository(this.data);
  final HomeDataModel data;
  var calls = 0;

  @override
  Future<Either<Failure, HomeDataModel>> getHome() async {
    calls++;
    return calls == 1 ? const Left(NetworkFailure()) : Right(data);
  }
}

void main() {
  final data = HomeDataModel.fromJson({
    'place': {
      'id': 18,
      'name': 'Mira',
      'slug': 'mira',
      'description': 'A neighborhood studio',
      'contact': {'address': 'Main Street', 'phone': '123456'},
      'open_now': false,
      'currency_symbol': '₪',
      'opening_hours': [
        {
          'day': 'sat',
          'label': 'Saturday',
          'open': true,
          'ranges': ['09:00 - 17:00'],
        },
      ],
    },
    'categories': [
      {'id': 18, 'name': 'Makeup', 'is_active': true},
    ],
    'featured': [],
    'popular': [
      {
        'id': 40,
        'name': 'Professional makeup',
        'slug': 'professional-makeup',
        'is_active': true,
        'final_price': 150,
        'duration_label': '1 hour',
      },
    ],
    'staff': [
      {'id': 27, 'name': 'Siham', 'initials': 'SA', 'is_active': true},
    ],
  });

  test('cubit loads the parsed home sections', () async {
    final cubit = HomeCubit(GetHome(_HomeRepository(data)));
    await cubit.fetchHome();
    expect(cubit.state, isA<HomeLoaded>());
    expect((cubit.state as HomeLoaded).data.popular.single.finalPrice, 150);
    await cubit.close();
  });

  test('cubit can retry after a failed load', () async {
    final repository = _RetryRepository(data);
    final cubit = HomeCubit(GetHome(repository));
    await cubit.fetchHome();
    expect(cubit.state, isA<HomeError>());
    await cubit.fetchHome();
    expect(cubit.state, isA<HomeLoaded>());
    expect(repository.calls, 2);
    await cubit.close();
  });

  testWidgets('home renders the place and available sections', (tester) async {
    final cubit = HomeCubit(GetHome(_HomeRepository(data)));
    final auth = _UnusedAuthRepository();
    final userCubit = UserCubit(
      Login(auth),
      Register(auth),
      RestoreSession(auth),
      UpdateProfile(auth),
      SignOut(auth),
    );
    await cubit.fetchHome();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: cubit),
          BlocProvider<UserCubit>.value(value: userCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    expect(find.text('Mira'), findsWidgets);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Makeup'), findsOneWidget);
    expect(find.text('A neighborhood studio'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('Main Street'), findsNothing);
    await tester.tap(find.text('About us'));
    await tester.pumpAndSettle();
    expect(find.text('A neighborhood studio'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
    expect(find.text('09:00 - 17:00'), findsOneWidget);
    expect(find.text('Main Street'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Professional makeup').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Professional makeup'), findsWidgets);
    await cubit.close();
    await userCubit.close();
  });
}
