import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/extensions/radius_extension.dart';
import 'package:booking_app/core/config/extensions/spacing_extension.dart';
import 'package:booking_app/core/config/theme/colors.dart';
import 'package:booking_app/core/config/theme/custom_themes/color_scheme.dart';
import 'package:booking_app/core/config/theme/custom_themes/text_theme.dart';
import 'package:booking_app/core/config/theme/radius.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/config/theme/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => build(AppColors.light, Brightness.light);
  static ThemeData get darkTheme => build(AppColors.dark, Brightness.dark);

  static ThemeData build(AppColorsExtension c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final text = AppTextTheme.build(c);

    // ---- shared button pieces -------------------------------------------
    bool disabled(Set<WidgetState> s) => s.contains(WidgetState.disabled);

    const minSize = WidgetStatePropertyAll(Size(0, AppSizes.buttonHeight));
    const padding = WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
    );
    const noElevation = WidgetStatePropertyAll<double>(0);
    final shape = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
    );
    final textStyle = WidgetStatePropertyAll<TextStyle?>(text.titleSmall);

    // Filled + Elevated share one style, and finally use hover/pressed tokens.
    final solidButton = ButtonStyle(
      minimumSize: minSize,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
      elevation: noElevation,
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
        if (disabled(s)) return c.disabledBg;
        if (s.contains(WidgetState.pressed)) return c.primaryPressed;
        if (s.contains(WidgetState.hovered)) return c.primaryHover;
        return c.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (s) => disabled(s) ? c.disabledText : c.onPrimary,
      ),
    );

    final outlinedButton = ButtonStyle(
      minimumSize: minSize,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (s) => disabled(s) ? c.disabledText : c.primary,
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (s) => BorderSide(color: disabled(s) ? c.disabledBorder : c.border),
      ),
    );

    final textButton = ButtonStyle(
      minimumSize: minSize,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (s) => disabled(s) ? c.disabledText : c.primary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: AppColorScheme.from(c, brightness),
      scaffoldBackgroundColor: c.background,

      fontFamily: AppTextTheme.fontFamily,
      fontFamilyFallback: AppTextTheme.fontFallback,
      textTheme: text,
      iconTheme: IconThemeData(color: c.textPrimary, size: AppSizes.iconLg),

      extensions: [c, const AppSpacingExtension(), const AppRadiusExtension()],

      // ---- surfaces & navigation ----------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryMuted,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.primary
                : c.textSecondary,
            size: AppSizes.iconLg,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall!.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.primary
                : c.textSecondary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: c.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: text.headlineMedium,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? c.surfaceMuted : c.textPrimary,
        contentTextStyle: text.bodyMedium!.copyWith(
          color: isDark ? c.textPrimary : c.textInverse,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.primaryMuted,
      ),

      // ---- inputs ---------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        hintStyle: text.bodyMedium!.copyWith(color: c.textSecondary),
        hintMaxLines: 1,
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: c.error.text),
        errorMaxLines: 2,
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
        border: _inputBorder(c.border),
        enabledBorder: _inputBorder(c.border),
        focusedBorder: _inputBorder(c.primary),
        errorBorder: _inputBorder(c.error.border),
        focusedErrorBorder: _inputBorder(c.error.border),
        disabledBorder: _inputBorder(c.disabledBorder),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionHandleColor: c.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.surface,
        ),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.selected) ? c.primary : c.border,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primaryMuted,
        disabledColor: c.disabledBg,
        checkmarkColor: c.primary,
        labelStyle: text.labelMedium,
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.disabledText
              : c.primary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.onPrimary
              : c.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.primary : c.disabledBg,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          side: WidgetStatePropertyAll(BorderSide(color: c.border)),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.primary
                : c.textSecondary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.primaryMuted
                : c.surface,
          ),
        ),
      ),

      // ---- buttons --------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(style: solidButton),
      elevatedButtonTheme: ElevatedButtonThemeData(style: solidButton),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButton),
      textButtonTheme: TextButtonThemeData(style: textButton),
      splashColor: c.primary.withValues(alpha: .08),
      highlightColor: Colors.transparent,
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(color: color),
    );
  }

  @Deprecated(
    'Direction should come from the locale: MaterialApp + the localization '
    'delegates make Arabic RTL and English LTR automatically.',
  )
  static Widget rtlBuilder(BuildContext context, Widget? child) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
