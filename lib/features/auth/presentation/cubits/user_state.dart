import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, guest, authenticated }

class UserState extends Equatable {
  const UserState({
    this.status = AuthStatus.initial,
    this.user,
    this.busy = false,
    this.failure,
    this.updated = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool busy;
  final Failure? failure;
  final bool updated;

  UserState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? busy,
    Failure? failure,
    bool? updated,
    bool clearFailure = false,
  }) => UserState(
    status: status ?? this.status,
    user: user ?? this.user,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : failure ?? this.failure,
    updated: updated ?? false,
  );

  @override
  List<Object?> get props => [status, user, busy, failure, updated];
}
