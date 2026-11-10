import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/extensions/radius_extension.dart';
import 'package:booking_app/core/config/extensions/spacing_extension.dart';
import 'package:booking_app/core/config/theme/colors.dart';
import 'package:flutter/material.dart';

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  AppColorsExtension get colors =>
      theme.extension<AppColorsExtension>() ??
      (isDark ? AppColors.dark : AppColors.light);

  AppSpacingExtension get spacing =>
      theme.extension<AppSpacingExtension>() ?? const AppSpacingExtension();

  AppRadiusExtension get radius =>
      theme.extension<AppRadiusExtension>() ?? const AppRadiusExtension();
}
