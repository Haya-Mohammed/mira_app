import 'package:flutter/material.dart';

enum AppStatus { success, warning, error, info }

@immutable
class AppStatusColors {
  const AppStatusColors({
    required this.bg,
    required this.border,
    required this.text,
  });

  final Color bg;
  final Color border;
  final Color text;

  AppStatusColors copyWith({Color? bg, Color? border, Color? text}) =>
      AppStatusColors(
        bg: bg ?? this.bg,
        border: border ?? this.border,
        text: text ?? this.text,
      );

  static AppStatusColors lerp(AppStatusColors a, AppStatusColors b, double t) =>
      AppStatusColors(
        bg: Color.lerp(a.bg, b.bg, t)!,
        border: Color.lerp(a.border, b.border, t)!,
        text: Color.lerp(a.text, b.text, t)!,
      );
}

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primaryMuted,
    required this.primaryBorderMuted,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.focusRing,
    required this.accentValue,
    required this.accentValueMuted,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.disabledBg,
    required this.disabledBorder,
    required this.disabledText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnMuted,
    required this.textInverse,
    required this.onError,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  // Brand
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color primaryMuted;
  final Color primaryBorderMuted;
  final Color onPrimary; // content on [primary]
  final Color onPrimaryMuted; // content on [primaryMuted]
  final Color focusRing;

  // Financial accent
  final Color accentValue;
  final Color accentValueMuted;
  final Color onAccent; // content on [accentValue]

  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceMuted;

  // Structure
  final Color border;
  final Color disabledBg;
  final Color disabledBorder;
  final Color disabledText;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnMuted;
  final Color textInverse;

  // Feedback
  final Color onError; // content on a solid [error.border] fill
  final AppStatusColors success;
  final AppStatusColors warning;
  final AppStatusColors error;
  final AppStatusColors info;

  AppStatusColors statusOf(AppStatus status) => switch (status) {
    AppStatus.success => success,
    AppStatus.warning => warning,
    AppStatus.error => error,
    AppStatus.info => info,
  };

  // Flat accessors kept so existing `colors.errorBorder` style code still works.
  Color get successBg => success.bg;
  Color get successBorder => success.border;
  Color get successText => success.text;
  Color get warningBg => warning.bg;
  Color get warningBorder => warning.border;
  Color get warningText => warning.text;
  Color get errorBg => error.bg;
  Color get errorBorder => error.border;
  Color get errorText => error.text;
  Color get infoBg => info.bg;
  Color get infoBorder => info.border;
  Color get infoText => info.text;

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? primaryMuted,
    Color? primaryBorderMuted,
    Color? onPrimary,
    Color? onPrimaryMuted,
    Color? focusRing,
    Color? accentValue,
    Color? accentValueMuted,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? disabledBg,
    Color? disabledBorder,
    Color? disabledText,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnMuted,
    Color? textInverse,
    Color? onError,
    AppStatusColors? success,
    AppStatusColors? warning,
    AppStatusColors? error,
    AppStatusColors? info,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primaryBorderMuted: primaryBorderMuted ?? this.primaryBorderMuted,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryMuted: onPrimaryMuted ?? this.onPrimaryMuted,
      focusRing: focusRing ?? this.focusRing,
      accentValue: accentValue ?? this.accentValue,
      accentValueMuted: accentValueMuted ?? this.accentValueMuted,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledText: disabledText ?? this.disabledText,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnMuted: textOnMuted ?? this.textOnMuted,
      textInverse: textInverse ?? this.textInverse,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColorsExtension(
      primary: l(primary, other.primary),
      primaryHover: l(primaryHover, other.primaryHover),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      primaryMuted: l(primaryMuted, other.primaryMuted),
      primaryBorderMuted: l(primaryBorderMuted, other.primaryBorderMuted),
      onPrimary: l(onPrimary, other.onPrimary),
      onPrimaryMuted: l(onPrimaryMuted, other.onPrimaryMuted),
      focusRing: l(focusRing, other.focusRing),
      accentValue: l(accentValue, other.accentValue),
      accentValueMuted: l(accentValueMuted, other.accentValueMuted),
      onAccent: l(onAccent, other.onAccent),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      border: l(border, other.border),
      disabledBg: l(disabledBg, other.disabledBg),
      disabledBorder: l(disabledBorder, other.disabledBorder),
      disabledText: l(disabledText, other.disabledText),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textOnMuted: l(textOnMuted, other.textOnMuted),
      textInverse: l(textInverse, other.textInverse),
      onError: l(onError, other.onError),
      success: AppStatusColors.lerp(success, other.success, t),
      warning: AppStatusColors.lerp(warning, other.warning, t),
      error: AppStatusColors.lerp(error, other.error, t),
      info: AppStatusColors.lerp(info, other.info, t),
    );
  }
}
