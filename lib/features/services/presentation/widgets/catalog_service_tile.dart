import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:booking_app/features/services/models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatalogServiceTile extends StatelessWidget {
  const CatalogServiceTile({
    super.key,
    required this.service,
    this.currency,
    required this.onTap,
  });

  final ServiceModel service;
  final String? currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amount = service.finalPrice ?? service.salePrice ?? service.price;
    final price = amount == null
        ? null
        : '${NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(amount)} ${currency ?? ''}'
              .trim();
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox.square(
                dimension: 96,
                child: RemoteImage(
                  url: service.thumb ?? service.image,
                  icon: Icons.spa_outlined,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                  if (service.durationLabel != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            service.durationLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (price != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryMuted,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        price,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
