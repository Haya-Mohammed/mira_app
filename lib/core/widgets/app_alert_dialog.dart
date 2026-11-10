import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppAlertDialog {
  AppAlertDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String actionText,
    required String cancelText,
    IconData icon = Icons.info_outline,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        final spacing = ctx.spacing;
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: destructive ? c.error.bg : c.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconLg,
                  color: destructive ? c.error.text : c.primary,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(content),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          actions: [
            AppButton(
              label: cancelText,
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.sm,
              expand: false,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            AppButton(
              label: actionText,
              variant: destructive
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
              size: AppButtonSize.sm,
              expand: false,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
