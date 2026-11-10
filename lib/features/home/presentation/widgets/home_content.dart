import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:booking_app/features/home/presentation/widgets/banner_strip.dart';
import 'package:booking_app/features/home/presentation/widgets/explore_links.dart';
import 'package:booking_app/features/home/presentation/widgets/home_heading.dart';
import 'package:booking_app/features/home/presentation/widgets/home_service_card.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:booking_app/features/home/presentation/widgets/review_card.dart';
import 'package:booking_app/features/home/presentation/widgets/staff_tile.dart';
import 'package:booking_app/features/services/presentation/screens/reviews_screen.dart';
import 'package:booking_app/features/services/presentation/screens/services_screen.dart';
import 'package:booking_app/features/services/presentation/screens/staff_screens.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.data});
  final HomeDataModel data;

  static const _sectionGap = 32.0;
  static const _headingGap = 14.0;

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final place = data.place!;
    final categories = data.categories.where((item) => item.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final featured = data.featured.where((item) => item.isActive).toList();
    final popular = data.popular.where((item) => item.isActive).toList();
    final staff = data.staff.where((item) => item.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final side = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 20.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(side, 8, side, 48),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.banners.isNotEmpty) ...[
                  BannerStrip(items: data.banners),
                  const SizedBox(height: _sectionGap),
                ],
                ExploreLinks(place: place),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: _sectionGap),
                  HomeHeading(
                    title: context.text.categories,
                    action: context.text.viewAll,
                    onAction: () => _open(context, const CategoryScreen()),
                  ),
                  const SizedBox(height: _headingGap),
                  SizedBox(
                    height: 164,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _CategoryTile(
                        name: categories[i].name,
                        image: categories[i].image,
                        onTap: () => _open(
                          context,
                          ServicesScreen(
                            categoryId: categories[i].id,
                            categoryName: categories[i].name,
                            currency: place.currencySymbol,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (featured.isNotEmpty) ...[
                  const SizedBox(height: _sectionGap),
                  HomeHeading(
                    title: context.text.featuredServices,
                    action: context.text.viewAll,
                    onAction: () => _open(context, ServicesScreen(currency: place.currencySymbol)),
                  ),
                  const SizedBox(height: _headingGap),
                  for (final service in featured)
                    HomeServiceCard(service: service, currency: place.currencySymbol),
                ],
                if (popular.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HomeHeading(
                    title: context.text.popularServices,
                    action: context.text.viewAll,
                    onAction: () => _open(context, ServicesScreen(currency: place.currencySymbol)),
                  ),
                  const SizedBox(height: _headingGap),
                  for (final service in popular)
                    HomeServiceCard(service: service, currency: place.currencySymbol),
                ],
                if (staff.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HomeHeading(
                    title: place.labels?.staffPlural ?? context.text.ourTeam,
                    action: context.text.viewAll,
                    onAction: () => _open(context, const StaffScreen()),
                  ),
                  const SizedBox(height: _headingGap),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: staff.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => StaffTile(staff: staff[i]),
                    ),
                  ),
                ],
                if (data.latestReviews.isNotEmpty) ...[
                  const SizedBox(height: _sectionGap),
                  HomeHeading(
                    title: context.text.latestReviews,
                    action: context.text.viewAll,
                    onAction: () => _open(context, const ReviewsScreen()),
                  ),
                  const SizedBox(height: _headingGap),
                  for (final review in data.latestReviews)
                    if (review is Map) ReviewCard(review: review),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Image tile with the category name set on a gradient at the bottom.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.name, required this.image, required this.onTap});
  final String name;
  final String? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 128,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(url: image, icon: Icons.spa_outlined),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: .72)],
                  stops: const [.4, 1],
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 12,
              end: 12,
              bottom: 12,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
