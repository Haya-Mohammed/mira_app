import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = context.textTheme;
    final spacing = context.spacing;

    final height = switch (size) {
      AppButtonSize.sm => AppSizes.touchTargetMin,
      AppButtonSize.md => 52.0,
      AppButtonSize.lg => AppSizes.buttonHeight,
    };
    final hPad = switch (size) {
      AppButtonSize.sm => spacing.md,
      AppButtonSize.md => spacing.lg,
      AppButtonSize.lg => spacing.xl,
    };
    final sizing = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expand ? double.infinity : 0, height),
      ),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: hPad)),
      textStyle: WidgetStatePropertyAll(
        size == AppButtonSize.sm ? text.labelMedium : text.labelLarge,
      ),
    );

    bool disabled(Set<WidgetState> s) => s.contains(WidgetState.disabled);
    bool pressed(Set<WidgetState> s) => s.contains(WidgetState.pressed);

    final ButtonStyle? variantStyle = switch (variant) {
      AppButtonVariant.primary => null,
      AppButtonVariant.danger => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (disabled(s)) return c.disabledBg;
          return pressed(s) ? c.error.text : c.error.border;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (s) => disabled(s) ? c.disabledText : c.onError,
        ),
      ),
      AppButtonVariant.secondary => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (disabled(s)) return c.disabledBg;
          return pressed(s) ? c.primaryMuted : c.surface;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
          (s) => BorderSide(
            color: disabled(s) ? c.disabledBorder : c.primaryBorderMuted,
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (s) => disabled(s) ? c.disabledText : c.primary,
        ),
      ),
      AppButtonVariant.ghost => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (s) => pressed(s) ? c.surfaceMuted : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (s) => disabled(s) ? c.disabledText : c.textSecondary,
        ),
      ),
    };
    final style = sizing.merge(variantStyle);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconMd),
          SizedBox(width: spacing.sm),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    final child = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: loading ? 0 : 1, child: content),
        if (loading)
          SizedBox.square(
            dimension: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color:
                  variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.danger
                  ? c.onPrimary
                  : c.primary,
            ),
          ),
      ],
    );

    final VoidCallback? onTap = loading ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => FilledButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
    };
  }
}
