import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._login,
    this._register,
    this._restore,
    this._update,
    this._signOut,
  ) : super(const UserState());

  final Login _login;
  final Register _register;
  final RestoreSession _restore;
  final UpdateProfile _update;
  final SignOut _signOut;
  int _revision = 0;

  void clearError() {
    if (state.failure != null) emit(state.copyWith(clearFailure: true));
  }

  Future<void> restore() async {
    final revision = ++_revision;
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    final result = await _restore();
    if (isClosed || revision != _revision) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AuthStatus.guest, failure: failure)),
      (user) => emit(
        UserState(
          status: user == null ? AuthStatus.guest : AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> login(String email, String password) async {
    if (state.busy) return;
    ++_revision;
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _login(email, password);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(busy: false, failure: failure)),
      (user) => emit(UserState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmation,
  ) async {
    if (state.busy) return;
    ++_revision;
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _register(name, email, phone, password, confirmation);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(busy: false, failure: failure)),
      (user) => emit(UserState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> updateProfile(String name, String email, String phone) async {
    if (state.busy) return;
    ++_revision;
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _update(name, email, phone);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) {
          emit(const UserState(status: AuthStatus.guest));
        } else {
          emit(state.copyWith(busy: false, failure: failure));
        }
      },
      (user) => emit(
        UserState(
          status: AuthStatus.authenticated,
          user: _withReliability(user, state.user?.reliability),
          updated: true,
        ),
      ),
    );
  }

  AuthUser _withReliability(AuthUser user, Reliability? reliability) =>
      AuthUser(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        roleLabel: user.roleLabel,
        avatar: user.avatar,
        initials: user.initials,
        cohort: user.cohort,
        isActive: user.isActive,
        lastLoginAt: user.lastLoginAt,
        createdAt: user.createdAt,
        reliability: user.reliability ?? reliability,
      );

  Future<void> signOut() async {
    if (state.busy) return;
    ++_revision;
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _signOut();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(busy: false, failure: failure)),
      (_) => emit(const UserState(status: AuthStatus.guest)),
    );
  }
}
