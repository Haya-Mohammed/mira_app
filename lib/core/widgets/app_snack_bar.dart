import 'package:booking_app/core/config/extensions/colors_extensions.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  static IconData _icon(AppStatus status) => switch (status) {
    AppStatus.success => Icons.check_circle_outline,
    AppStatus.warning => Icons.warning_amber_rounded,
    AppStatus.error => Icons.error_outline,
    AppStatus.info => Icons.info_outline,
  };

  static void show(
    BuildContext context,
    String message, {
    required AppStatus status,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final s = context.colors.statusOf(status);
    final spacing = context.spacing;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: s.bg,
          duration: duration,
          shape: RoundedRectangleBorder(
            borderRadius: context.radius.mdAll,
            side: BorderSide(color: s.border),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon(status), color: s.text),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(color: s.text),
                ),
              ),
            ],
          ),
          action: action,
        ),
      );
  }
}
