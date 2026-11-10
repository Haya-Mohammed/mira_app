import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:dartz/dartz.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthUser>> login(String email, String password);
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  );
  Future<Either<Failure, AuthUser?>> restoreSession();
  Future<Either<Failure, AuthUser>> updateProfile(
    String name,
    String email,
    String phone,
  );
  Future<Either<Failure, Unit>> signOut();
}
