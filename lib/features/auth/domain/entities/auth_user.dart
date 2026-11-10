import 'package:equatable/equatable.dart';

class Reliability extends Equatable {
  const Reliability({
    required this.score,
    required this.level,
    required this.label,
    required this.completed,
    required this.noShows,
    required this.lateCancellations,
    required this.total,
  });

  final int score, completed, noShows, lateCancellations, total;
  final String level, label;

  @override
  List<Object?> get props => [
    score,
    level,
    label,
    completed,
    noShows,
    lateCancellations,
    total,
  ];
}

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.roleLabel,
    this.avatar,
    required this.initials,
    this.cohort,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    this.reliability,
  });

  final int id;
  final String name, email, phone, role, roleLabel, initials, createdAt;
  final String? avatar, cohort, lastLoginAt;
  final bool isActive;
  final Reliability? reliability;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    roleLabel,
    avatar,
    initials,
    cohort,
    isActive,
    lastLoginAt,
    createdAt,
    reliability,
  ];
}
