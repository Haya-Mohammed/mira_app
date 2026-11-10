import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:booking_app/features/services/models/service_model.dart';
import 'package:booking_app/features/services/presentation/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeServiceCard extends StatelessWidget {
  const HomeServiceCard({
    super.key,
    required this.service,
    required this.currency,
  });
  final ServiceModel service;
  final String? currency;

  String get price {
    final amount = service.finalPrice ?? service.salePrice ?? service.price;
    if (amount == null) return '';
    return '${NumberFormat.decimalPattern().format(amount)} ${currency ?? ''}'
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                ServiceDetailsScreen(serviceId: service.id, currency: currency),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox.square(
                  dimension: 88,
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
                    if (service.durationLabel?.isNotEmpty == true) ...[
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
                    if (price.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        price,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
