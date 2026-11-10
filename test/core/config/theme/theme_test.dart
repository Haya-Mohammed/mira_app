import 'package:booking_app/core/config/theme/palette.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mira theme uses the specified brand surfaces and touch sizes', () {
    final theme = AppTheme.lightTheme;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppPalette.primary);
    expect(theme.scaffoldBackgroundColor, AppPalette.warmWhite);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F6F6));
    expect(theme.colorScheme.surface, AppPalette.white);
    expect(AppSizes.touchTargetMin, greaterThanOrEqualTo(48));
    expect(
      theme.filledButtonTheme.style!.minimumSize!.resolve({})!.height,
      AppSizes.buttonHeight,
    );
  });

  test('dark theme keeps readable surfaces and a distinct primary', () {
    final theme = AppTheme.darkTheme;

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.onSurface, isNot(theme.colorScheme.surface));
    expect(theme.colorScheme.primary, AppPalette.darkPrimary);
  });
}
