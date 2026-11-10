import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: context.colors.primary),
            ),
            SizedBox(height: context.spacing.md),
            Text(
              title,
              style: context.textTheme.headlineMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
