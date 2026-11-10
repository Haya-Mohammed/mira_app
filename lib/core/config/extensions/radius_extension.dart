import 'package:booking_app/core/config/theme/radius.dart';
import 'package:flutter/material.dart';

@immutable
class AppRadiusExtension extends ThemeExtension<AppRadiusExtension> {
  const AppRadiusExtension();

  double get sm => AppRadius.sm;
  double get md => AppRadius.md;
  double get lg => AppRadius.lg;
  double get xl => AppRadius.xl;
  double get pill => AppRadius.pill;

  double get card => AppRadius.lg;
  double get sheet => AppRadius.lg;

  BorderRadius get smAll => AppRadius.smAll;
  BorderRadius get mdAll => AppRadius.mdAll;
  BorderRadius get lgAll => AppRadius.lgAll;
  BorderRadius get xlAll => AppRadius.xlAll;
  BorderRadius get pillAll => AppRadius.pillAll;
  BorderRadius get sheetTop => AppRadius.sheetTop;

  @override
  AppRadiusExtension copyWith() => this;

  @override
  AppRadiusExtension lerp(
    ThemeExtension<AppRadiusExtension>? other,
    double t,
  ) => this;
}
