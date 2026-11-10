import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class Login {
  const Login(this.repository);
  final AuthRepository repository;
  Future<Either<Failure, AuthUser>> call(String email, String password) =>
      repository.login(email, password);
}

class Register {
  const Register(this.repository);
  final AuthRepository repository;
  Future<Either<Failure, AuthUser>> call(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) => repository.register(name, email, phone, password, confirmation);
}

class RestoreSession {
  const RestoreSession(this.repository);
  final AuthRepository repository;
  Future<Either<Failure, AuthUser?>> call() => repository.restoreSession();
}

class UpdateProfile {
  const UpdateProfile(this.repository);
  final AuthRepository repository;
  Future<Either<Failure, AuthUser>> call(
    String name,
    String email,
    String phone,
  ) => repository.updateProfile(name, email, phone);
}

class SignOut {
  const SignOut(this.repository);
  final AuthRepository repository;
  Future<Either<Failure, Unit>> call() => repository.signOut();
}
