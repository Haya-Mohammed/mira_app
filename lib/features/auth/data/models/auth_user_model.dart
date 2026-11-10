import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    required super.roleLabel,
    super.avatar,
    required super.initials,
    super.cohort,
    required super.isActive,
    super.lastLoginAt,
    required super.createdAt,
    super.reliability,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    try {
      final reliability = json['reliability'];
      return AuthUserModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? '',
        roleLabel: json['role_label'] as String? ?? '',
        avatar: json['avatar'] as String?,
        initials: json['initials'] as String? ?? '',
        cohort: json['cohort'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        lastLoginAt: json['last_login_at'] as String?,
        createdAt: json['created_at'] as String? ?? '',
        reliability: reliability is Map<String, dynamic>
            ? Reliability(
                score: (reliability['score'] as num?)?.toInt() ?? 0,
                level: reliability['level'] as String? ?? '',
                label: reliability['label'] as String? ?? '',
                completed: (reliability['completed'] as num?)?.toInt() ?? 0,
                noShows: (reliability['no_shows'] as num?)?.toInt() ?? 0,
                lateCancellations:
                    (reliability['late_cancellations'] as num?)?.toInt() ?? 0,
                total: (reliability['total'] as num?)?.toInt() ?? 0,
              )
            : null,
      );
    } catch (_) {
      throw const UnknownException(message: 'Invalid user response');
    }
  }
}
