import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/services/storage/secure_storage_service.dart';
import 'package:booking_app/core/services/storage/storage_keys.dart';
import 'package:booking_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:booking_app/features/auth/data/models/auth_user_model.dart';
import 'package:booking_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUserModel(
  id: 1,
  name: 'A',
  email: 'a@example.com',
  phone: '0599000111',
  role: 'customer',
  roleLabel: 'Customer',
  initials: 'A',
  isActive: true,
  createdAt: '2026-10-19T07:22:31+00:00',
);

class _Remote implements AuthRemoteDatasource {
  bool unauthorized = false;
  bool logoutFailed = false;
  bool logoutCalled = false;
  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutFailed) throw const NetworkException();
  }

  @override
  Future<AuthSessionResponse> login(String email, String password) async =>
      const AuthSessionResponse('42|token', _user);
  @override
  Future<AuthSessionResponse> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) async => const AuthSessionResponse('43|token', _user);
  @override
  Future<AuthUserModel> me() async {
    if (unauthorized) throw const UnauthorizedException(statusCode: 401);
    return _user;
  }

  @override
  Future<AuthUserModel> updateProfile(
    String name,
    String email,
    String phone,
  ) async {
    if (unauthorized) throw const UnauthorizedException(statusCode: 401);
    return _user;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('persists a session, restores it, and clears it on sign out', () async {
    const storage = SecureStorageService(FlutterSecureStorage());
    final remote = _Remote();
    final repository = AuthRepositoryImpl(remote, storage);
    expect(
      (await repository.login('a@example.com', 'password')).isRight(),
      true,
    );
    expect(await storage.read(StorageKeys.accessToken), '42|token');
    expect((await repository.restoreSession()).isRight(), true);
    expect((await repository.signOut()).isRight(), true);
    expect(remote.logoutCalled, isTrue);
    expect(await storage.read(StorageKeys.accessToken), isNull);
  });

  test('keeps session when server logout fails', () async {
    const storage = SecureStorageService(FlutterSecureStorage());
    await storage.write(StorageKeys.accessToken, '42|token');
    final result = await AuthRepositoryImpl(
      _Remote()..logoutFailed = true,
      storage,
    ).signOut();
    expect(result.isLeft(), isTrue);
    expect(await storage.read(StorageKeys.accessToken), '42|token');
  });

  test('clears an expired token while restoring', () async {
    const storage = SecureStorageService(FlutterSecureStorage());
    await storage.write(StorageKeys.accessToken, 'expired');
    final remote = _Remote()..unauthorized = true;
    final result = await AuthRepositoryImpl(remote, storage).restoreSession();
    expect(result.fold((_) => false, (user) => user == null), true);
    expect(await storage.read(StorageKeys.accessToken), isNull);
  });
}
