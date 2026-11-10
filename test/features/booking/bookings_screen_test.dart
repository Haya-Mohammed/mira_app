import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/services/api/dio_client.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:booking_app/features/booking/presentation/bookings_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, AuthUser>> login(
    String email,
    String password,
  ) async => const Right(
    AuthUser(
      id: 1,
      name: 'Sara',
      email: 'sara@example.com',
      phone: '0599',
      role: 'customer',
      roleLabel: 'Customer',
      initials: 'S',
      isActive: true,
      createdAt: '',
    ),
  );

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

class _BookingSource extends BookingRemoteDatasource {
  _BookingSource() : super(DioClient(Dio()));
  final scopes = <String>[];

  @override
  Future<BookingPage> getBookings({
    String scope = 'upcoming',
    int page = 1,
  }) async {
    scopes.add(scope);
    if (scope == 'past') return const BookingPage([], 1, 1);
    return BookingPage(
      [
        BookingRecord.fromJson({
          'id': 7,
          'number': 'M-123',
          'status': 'confirmed',
          'status_label': 'Confirmed',
          'service_name': 'Haircut',
          'staff_name': 'Reem',
          'date': '2026-10-23',
          'time': '16:30',
          'timeline': <dynamic>[],
        }),
      ],
      1,
      1,
    );
  }
}

void main() {
  testWidgets('guest sees sign in prompt without loading bookings', (
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
    final source = _BookingSource();
    sl.registerSingleton<BookingRemoteDatasource>(source);
    addTearDown(() async {
      await cubit.close();
      await sl.reset();
    });
    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();
    expect(
      find.text('Sign in to view and manage your bookings.'),
      findsOneWidget,
    );
    expect(find.text('Upcoming'), findsNothing);
    expect(source.scopes, isEmpty);
  });

  testWidgets('booking card and past empty state follow the selected tab', (
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
    final source = _BookingSource();
    sl.registerSingleton<BookingRemoteDatasource>(source);
    addTearDown(() async {
      await cubit.close();
      await sl.reset();
    });
    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Haircut'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Reem'), findsOneWidget);
    expect(find.text('#M-123'), findsOneWidget);
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();
    expect(source.scopes, ['upcoming', 'past']);
    expect(find.text('You have no past bookings.'), findsOneWidget);
    expect(find.text('Haircut'), findsNothing);
  });
}

Widget _app(UserCubit cubit) => BlocProvider<UserCubit>.value(
  value: cubit,
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const BookingsScreen(),
  ),
);
