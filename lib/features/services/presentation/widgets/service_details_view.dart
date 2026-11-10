part of '../screens/service_details_screen.dart';

class _ServiceDetailsView extends StatelessWidget {
  const _ServiceDetailsView({required this.serviceId, this.currency});
  final int serviceId;
  final String? currency;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.text.services),
      scrolledUnderElevation: 0,
    ),
    // A sticky bar keeps the price and the main action always in reach.
    bottomNavigationBar:
        BlocBuilder<
          ResourceCubit<ServiceDetails>,
          ResourceState<ServiceDetails>
        >(
          builder: (context, state) {
            if (state is! ResourceLoaded<ServiceDetails>) {
              return const SizedBox.shrink();
            }
            final service = state.data.service;
            return _BookBar(
              price: _formatPrice(context, service, currency),
              onBook: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      BookingFlowScreen(service: service, currency: currency),
                ),
              ),
            );
          },
        ),
    body: BlocBuilder<ResourceCubit<ServiceDetails>, ResourceState<ServiceDetails>>(
      builder: (context, state) {
        if (state is ResourceLoading<ServiceDetails>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ResourceError<ServiceDetails>) {
          return AppErrorView(
            message: state.failure.localized(context),
            onRetry: context.read<ResourceCubit<ServiceDetails>>().load,
          );
        }
        final colors = context.colors;
        final details = (state as ResourceLoaded<ServiceDetails>).data;
        final service = details.service;
        final hasRating = details.rating != null && details.rating!.count > 0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: RemoteImage(
                          url: service.image,
                          icon: Icons.spa_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(service.name, style: context.textTheme.headlineLarge),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (service.durationLabel != null)
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: service.durationLabel!,
                            iconColor: colors.primary,
                          ),
                        if (hasRating)
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label:
                                '${details.rating!.average.toStringAsFixed(1)} (${details.rating!.count})',
                            iconColor: const Color(0xFFF5A623),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        service.description?.isNotEmpty == true
                            ? service.description!
                            : context.text.noDescription,
                        style: context.textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                        ),
                      ),
                    ),
                    if (service.staff.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      HomeHeading(title: context.text.staff),
                      const SizedBox(height: 14),
                      for (final person in service.staff)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    StaffDetailsScreen(staffId: person.id),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: colors.primaryMuted,
                                  child: Text(
                                    person.initials ??
                                        person.name.characters.first,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(color: colors.primary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.titleMedium,
                                      ),
                                      if (person.title != null)
                                        Text(
                                          person.title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodyMedium,
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 22),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ReviewsScreen(serviceId: serviceId),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.primaryMuted,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.rate_review_outlined,
                              size: 22,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.text.reviews,
                                  style: context.textTheme.titleMedium,
                                ),
                                Text(
                                  hasRating
                                      ? '★ ${details.rating!.average.toStringAsFixed(1)} (${details.rating!.count})'
                                      : context.text.noReviews,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
