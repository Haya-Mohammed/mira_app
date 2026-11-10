import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/exception_handler.dart';
import 'package:booking_app/core/services/storage/secure_storage_service.dart';
import 'package:booking_app/core/services/storage/storage_keys.dart';
import 'package:booking_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);
  final AuthRemoteDatasource _remote;
  final SecureStorageService _storage;

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) =>
      guard(() async {
        final session = await _remote.login(email, password);
        await _storage.write(StorageKeys.accessToken, session.token);
        return session.user;
      });

  @override
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) => guard(() async {
    final session = await _remote.register(
      name,
      email,
      phone,
      password,
      confirmation,
    );
    await _storage.write(StorageKeys.accessToken, session.token);
    return session.user;
  });

  @override
  Future<Either<Failure, AuthUser?>> restoreSession() => guard(() async {
    final token = await _storage.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return null;
    try {
      return await _remote.me();
    } on UnauthorizedException {
      await _storage.delete(StorageKeys.accessToken);
      return null;
    }
  });

  @override
  Future<Either<Failure, AuthUser>> updateProfile(
    String name,
    String email,
    String phone,
  ) => guard(() async {
    try {
      return await _remote.updateProfile(name, email, phone);
    } on UnauthorizedException {
      await _storage.delete(StorageKeys.accessToken);
      rethrow;
    }
  });

  @override
  Future<Either<Failure, Unit>> signOut() => guard(() async {
    await _remote.logout();
    await _storage.delete(StorageKeys.accessToken);
    return unit;
  });
}
