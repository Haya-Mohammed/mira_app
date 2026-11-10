import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTextTheme {
  static const String fontFamily = 'Cairo';
  static const List<String> fontFallback = ['IBM Plex Sans Arabic'];

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color, {
    required double lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      fontSize: size,
      fontWeight: weight,
      height: lineHeight / size,
      color: color,

      letterSpacing: 0,
    );
  }

  static TextTheme build(AppColorsExtension c) {
    final primary = c.textPrimary;
    final secondary = c.textSecondary;

    final display = _style(32, FontWeight.w700, primary, lineHeight: 42);
    final h1 = _style(27, FontWeight.w700, primary, lineHeight: 38);
    final h2 = _style(21, FontWeight.w700, primary, lineHeight: 30);
    final h3 = _style(18, FontWeight.w600, primary, lineHeight: 28);

    return TextTheme(
      displayLarge: display,
      displayMedium: h1,
      displaySmall: h2,
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h3, // AppBar title
      titleMedium: _style(16, FontWeight.w600, primary, lineHeight: 26),
      titleSmall: _style(14, FontWeight.w600, primary, lineHeight: 22),
      bodyLarge: _style(16, FontWeight.w400, primary, lineHeight: 26),
      bodyMedium: _style(14, FontWeight.w400, secondary, lineHeight: 23),
      bodySmall: _style(12, FontWeight.w500, secondary, lineHeight: 20),
      labelLarge: _style(14, FontWeight.w600, primary, lineHeight: 22),
      labelMedium: _style(14, FontWeight.w600, primary, lineHeight: 22),
      labelSmall: _style(12, FontWeight.w500, secondary, lineHeight: 20),
    );
  }

  static TextTheme get lightTextTheme => build(AppColors.light);
  static TextTheme get darkTextTheme => build(AppColors.dark);
}
