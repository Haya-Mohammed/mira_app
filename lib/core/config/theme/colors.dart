import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/theme/palette.dart';
import 'package:flutter/painting.dart';

abstract final class AppColors {
  static const light = AppColorsExtension(
    primary: AppPalette.primary,
    primaryHover: AppPalette.primaryDark,
    primaryPressed: AppPalette.primaryDark,
    primaryMuted: AppPalette.blush,
    primaryBorderMuted: AppPalette.border,
    onPrimary: AppPalette.white,
    onPrimaryMuted: AppPalette.primaryDark,
    focusRing: Color(0x55B50922),
    accentValue: AppPalette.accentRose,
    accentValueMuted: AppPalette.blush,
    onAccent: AppPalette.white,
    background: AppPalette.warmWhite,
    surface: AppPalette.white,
    surfaceMuted: AppPalette.blush,
    border: AppPalette.border,
    disabledBg: AppPalette.disabledSurface,
    disabledBorder: AppPalette.border,
    disabledText: AppPalette.textSecondary,
    textPrimary: AppPalette.textPrimary,
    textSecondary: AppPalette.textSecondary,
    textOnMuted: AppPalette.textPrimary,
    textInverse: AppPalette.white,
    onError: AppPalette.white,
    success: AppStatusColors(
      bg: Color(0xFFE8F5EF),
      border: AppPalette.success,
      text: Color(0xFF15593D),
    ),
    warning: AppStatusColors(
      bg: Color(0xFFFFF4DC),
      border: AppPalette.warning,
      text: Color(0xFF734900),
    ),
    error: AppStatusColors(
      bg: Color(0xFFFFEDEC),
      border: AppPalette.error,
      text: AppPalette.error,
    ),
    info: AppStatusColors(
      bg: Color(0xFFEAF2FA),
      border: Color(0xFF28649B),
      text: Color(0xFF194C7A),
    ),
  );

  static const dark = AppColorsExtension(
    primary: AppPalette.darkPrimary,
    primaryHover: Color(0xFFFFA5B1),
    primaryPressed: Color(0xFFFFB7C0),
    primaryMuted: AppPalette.darkSurfaceMuted,
    primaryBorderMuted: AppPalette.darkBorder,
    onPrimary: AppPalette.textPrimary,
    onPrimaryMuted: AppPalette.darkText,
    focusRing: Color(0x66FF8092),
    accentValue: Color(0xFFFFA0AD),
    accentValueMuted: AppPalette.darkSurfaceMuted,
    onAccent: AppPalette.textPrimary,
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    surfaceMuted: AppPalette.darkSurfaceMuted,
    border: AppPalette.darkBorder,
    disabledBg: AppPalette.darkSurfaceMuted,
    disabledBorder: AppPalette.darkBorder,
    disabledText: AppPalette.darkTextSecondary,
    textPrimary: AppPalette.darkText,
    textSecondary: AppPalette.darkTextSecondary,
    textOnMuted: AppPalette.darkText,
    textInverse: AppPalette.textPrimary,
    onError: AppPalette.white,
    success: AppStatusColors(
      bg: Color(0xFF173A2D),
      border: Color(0xFF63C49A),
      text: Color(0xFFB1EACF),
    ),
    warning: AppStatusColors(
      bg: Color(0xFF433315),
      border: Color(0xFFE0B85D),
      text: Color(0xFFFFE0A0),
    ),
    error: AppStatusColors(
      bg: Color(0xFF481F22),
      border: Color(0xFFFF8690),
      text: Color(0xFFFFBBC1),
    ),
    info: AppStatusColors(
      bg: Color(0xFF1B3044),
      border: Color(0xFF79B2E2),
      text: Color(0xFFB7DCF8),
    ),
  );
}
