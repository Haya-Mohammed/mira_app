import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/features/home/data/models/place_model.dart';
import 'package:booking_app/features/home/presentation/widgets/contact_row.dart';
import 'package:booking_app/features/home/presentation/widgets/home_heading.dart';
import 'package:flutter/material.dart';

class PlaceInfoScreen extends StatelessWidget {
  const PlaceInfoScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contact = place.contact;
    final hasContact =
        contact?.address?.isNotEmpty == true ||
        contact?.phone?.isNotEmpty == true ||
        contact?.whatsapp?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.aboutUs),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (place.description?.isNotEmpty == true) ...[
                    HomeHeading(title: context.text.aboutUs),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        place.description!,
                        style: context.textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                  if (place.openingHours.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    HomeHeading(title: context.text.openingHours),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          for (final hours in place.openingHours) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hours.label ?? hours.day,
                                      style: context.textTheme.titleSmall,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      hours.open && hours.ranges.isNotEmpty
                                          ? hours.ranges.join(', ')
                                          : context.text.closed,
                                      textAlign: TextAlign.end,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                hours.open &&
                                                    hours.ranges.isNotEmpty
                                                ? null
                                                : colors.textSecondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hours != place.openingHours.last)
                              Divider(height: 1, color: colors.border),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (contact != null && hasContact) ...[
                    const SizedBox(height: 28),
                    HomeHeading(title: context.text.contactUs),
                    const SizedBox(height: 12),
                    if (contact.address?.isNotEmpty == true)
                      ContactRow(Icons.location_on_outlined, contact.address!),
                    if (contact.phone?.isNotEmpty == true)
                      ContactRow(Icons.phone_outlined, contact.phone!),
                    if (contact.whatsapp?.isNotEmpty == true)
                      ContactRow(Icons.chat_outlined, contact.whatsapp!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
