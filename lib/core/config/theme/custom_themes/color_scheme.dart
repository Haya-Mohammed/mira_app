import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class AppColorScheme {
  static ColorScheme from(AppColorsExtension c, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryMuted,
      onPrimaryContainer: c.onPrimaryMuted,
      secondary: c.accentValue,
      onSecondary: c.onAccent,
      secondaryContainer: c.warning.bg,
      onSecondaryContainer: c.warning.text,
      error: c.error.border,
      onError: c.onError,
      errorContainer: c.error.bg,
      onErrorContainer: c.error.text,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.border,
      outlineVariant: c.disabledBorder,
    );
  }

  static ColorScheme get light => from(AppColors.light, Brightness.light);
  static ColorScheme get dark => from(AppColors.dark, Brightness.dark);
}
