import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/features/home/data/models/place_model.dart';
import 'package:booking_app/features/home/presentation/screens/place_info_screen.dart';
import 'package:booking_app/features/home/presentation/widgets/explore_link.dart';
import 'package:booking_app/features/services/presentation/screens/busy_hours_screen.dart';
import 'package:booking_app/features/services/presentation/screens/reviews_screen.dart';
import 'package:booking_app/features/services/presentation/screens/services_screen.dart';
import 'package:booking_app/features/services/presentation/screens/staff_screens.dart';
import 'package:flutter/material.dart';

class ExploreLinks extends StatelessWidget {
  const ExploreLinks({super.key, required this.place});
  final PlaceModel place;

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  bool get _hasInfo =>
      place.description?.isNotEmpty == true ||
      place.openingHours.isNotEmpty ||
      place.contact?.address?.isNotEmpty == true ||
      place.contact?.phone?.isNotEmpty == true ||
      place.contact?.whatsapp?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final items = <ExploreLink>[
      ExploreLink(
        icon: Icons.spa_outlined,
        label: context.text.services,
        onTap: () =>
            _open(context, ServicesScreen(currency: place.currencySymbol)),
      ),
      ExploreLink(
        icon: Icons.people_outline_rounded,
        label: context.text.staff,
        onTap: () => _open(context, const StaffScreen()),
      ),
      ExploreLink(
        icon: Icons.rate_review_outlined,
        label: context.text.reviews,
        onTap: () => _open(context, const ReviewsScreen()),
      ),
      ExploreLink(
        icon: Icons.schedule_outlined,
        label: context.text.busyHours,
        onTap: () => _open(context, const BusyHoursScreen()),
      ),
      if (_hasInfo)
        ExploreLink(
          icon: Icons.info_outline_rounded,
          label: context.text.aboutUs,
          onTap: () => _open(context, PlaceInfoScreen(place: place)),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        // Tiles share the row evenly; if they get too narrow the row scrolls.
        final width =
            ((constraints.maxWidth - gap * (items.length - 1)) / items.length)
                .clamp(78.0, 160.0)
                .toDouble();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                SizedBox(width: width, child: items[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}
