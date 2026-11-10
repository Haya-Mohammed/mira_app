import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/features/home/data/models/place_model.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:flutter/material.dart';

/// Immersive hero: the cover photo carries the identity (logo, name,
/// tagline) and the live signals (rating, open/closed). A slim footer below
/// holds the practical details (type, address).
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.place});
  final PlaceModel place;

  static const _radius = 28.0;

  @override
  Widget build(BuildContext context) {
    final hasType = place.type != null;
    final address = place.contact?.address;
    final hasAddress = address?.isNotEmpty == true;
    final hasFooter = hasType || hasAddress;

    return AppCard(
      padding: EdgeInsets.zero,
      border: Border.all(color: Colors.transparent),
      borderRadius: _radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: hasFooter
                ? const BorderRadius.vertical(top: Radius.circular(_radius))
                : BorderRadius.circular(_radius),
            child: _Cover(place: place),
          ),
          if (hasFooter)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasType) _MetaChip(icon: Icons.storefront_outlined, label: place.type!.name),
                  if (hasType && hasAddress) const SizedBox(height: 12),
                  if (hasAddress)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: context.colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final hasLogo = place.logo?.isNotEmpty == true;
    final hasRating = place.rating?.count != null && place.rating!.count > 0;
    final hasTagline = place.tagline?.isNotEmpty == true;
    const shadow = [Shadow(blurRadius: 10, color: Colors.black45)];

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: place.cover, icon: Icons.spa_outlined),
          // Darkens the top (for the pills) and the bottom (for the text).
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .30),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .80),
                ],
                stops: const [0, .35, 1],
              ),
            ),
          ),
          // Top row: rating (start) · status (end)
          PositionedDirectional(
            top: 14,
            start: 14,
            end: 14,
            child: Row(
              children: [
                if (hasRating)
                  _RatingPill(
                    average: place.rating!.average.toDouble(),
                    count: place.rating!.count,
                  ),
                const Spacer(),
                _StatusChip(open: place.openNow),
              ],
            ),
          ),
          // Bottom: logo + name + tagline
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasLogo) ...[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: SizedBox.square(
                        dimension: 60,
                        child: RemoteImage(url: place.logo, icon: Icons.spa_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          shadows: shadow,
                        ),
                      ),
                      if (hasTagline) ...[
                        const SizedBox(height: 4),
                        Text(
                          place.tagline!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: .9),
                            shadows: shadow,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark translucent pill so the rating stays readable on any photo.
class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.average, required this.count});
  final double average;
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5A623)),
        const SizedBox(width: 4),
        Text(
          average.toStringAsFixed(1),
          style: context.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: context.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: .8)),
        ),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.open});
  final bool open;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = open ? colors.success.text : colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: open ? colors.success.bg : colors.disabledBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            open ? context.text.openNow : context.text.closedNow,
            style: context.textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: context.colors.primaryMuted,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colors.primary),
        const SizedBox(width: 6),
        Text(label, style: context.textTheme.labelMedium),
      ],
    ),
  );
}
