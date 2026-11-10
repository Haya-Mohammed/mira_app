import 'package:booking_app/core/config/theme/themes.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BoxBorder? border;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? context.radius.xl;
    final r = BorderRadius.circular(effectiveRadius);
    final surface = color ?? context.colors.surface;

    Widget content = child ?? const SizedBox.shrink();
    if (padding != null && padding != EdgeInsets.zero) {
      content = Padding(padding: padding!, child: content);
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: r,
        border:
            border ?? Border.all(color: borderColor ?? context.colors.border),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: context.colors.textPrimary.withValues(alpha: .035),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
