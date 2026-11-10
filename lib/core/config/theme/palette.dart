import 'package:flutter/painting.dart';

/// Mira brand and semantic colors.
abstract final class AppPalette {
  static const white = Color(0xFFFFFFFF);
  static const warmWhite = Color(0xFFF6F6F6);
  static const primary = Color(0xFFB50922);
  static const primaryDark = Color(0xFF800719);
  static const accentRose = Color(0xFFD93B50);
  static const blush = Color(0xFFFCE8EB);
  static const textPrimary = Color(0xFF252126);
  static const textSecondary = Color(0xFF746E73);
  static const border = Color(0xFFEAE6E8);
  static const disabledSurface = Color(0xFFF0EEEE);
  static const success = Color(0xFF217A55);
  static const warning = Color(0xFF9A6300);
  static const error = Color(0xFFB42318);

  static const darkBackground = Color(0xFF1B1416);
  static const darkSurface = Color(0xFF2A2023);
  static const darkSurfaceMuted = Color(0xFF382A2E);
  static const darkBorder = Color(0xFF59454B);
  static const darkText = Color(0xFFFFF7F8);
  static const darkTextSecondary = Color(0xFFD8C4CA);
  static const darkPrimary = Color(0xFFFF8092);
}
