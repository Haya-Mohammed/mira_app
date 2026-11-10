import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ContactRow extends StatelessWidget {
  const ContactRow(this.icon, this.value, {super.key});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colors.primaryMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconLg,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(value, style: context.textTheme.bodyLarge)),
        ],
      ),
    ),
  );
}
