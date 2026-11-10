import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/config/theme/spacing.dart';
import 'package:flutter/material.dart';

/// Exposes [AppSpacing] through `context.spacing`. Holds no values of its own.
@immutable
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension();

  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get base => AppSpacing.base;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
  double get xxxl => AppSpacing.xxxl;
  double get xxxxl => AppSpacing.xxxxl;

  @Deprecated('Use xxl')
  double get xl2 => AppSpacing.xxl;

  @Deprecated('Use AppSizes.touchTargetMin')
  double get touchTargetMin => AppSizes.touchTargetMin;

  @override
  AppSpacingExtension copyWith() => this;

  @override
  AppSpacingExtension lerp(
    ThemeExtension<AppSpacingExtension>? other,
    double t,
  ) => this;
}
