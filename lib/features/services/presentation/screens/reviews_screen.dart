import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/review_card.dart';
part '../widgets/stars.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, this.serviceId});
  final int? serviceId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ReviewsCubit(sl(), serviceId: serviceId)..load(),
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.text.reviews),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          final cubit = context.read<ReviewsCubit>();

          // First load: skeleton cards instead of a lone spinner.
          if (state.loading && state.items.isEmpty) {
            return const _ReviewsSkeleton();
          }
          if (state.failure != null && state.items.isEmpty) {
            return AppErrorView(
              message: state.failure!.localized(context),
              onRetry: cubit.load,
            );
          }
          if (state.items.isEmpty) {
            return AppEmptyView(
              icon: Icons.rate_review_outlined,
              title: context.text.noReviews,
              subtitle: context.text.reviews,
            );
          }

          final hasNext = state.meta?.hasNextPage == true;
          final hasFooter = hasNext || state.failure != null;

          return RefreshIndicator(
            onRefresh: cubit.load,
            // Infinite scroll: fetch the next page before the user hits the
            // bottom. The "load more" button remains as a fallback.
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.vertical &&
                    notification.metrics.extentAfter < 320 &&
                    hasNext &&
                    state.failure == null &&
                    !state.loadingMore &&
                    !state.loading) {
                  cubit.loadMore();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: state.items.length + (hasFooter ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index < state.items.length) {
                    return _ReviewCard(state.items[index]);
                  }
                  return _Footer(
                    state: state,
                    onRetry: cubit.loadMore,
                  );
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// Bottom of the list: spinner while loading, retry on failure, button as a
/// manual fallback.
class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final ReviewsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (state.failure != null) {
      return Column(
        children: [
          Text(
            state.failure!.localized(context),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: context.text.loadMore,
            onPressed: onRetry,
            variant: AppButtonVariant.secondary,
          ),
        ],
      );
    }
    return AppButton(
      label: context.text.loadMore,
      onPressed: onRetry,
      variant: AppButtonVariant.secondary,
    );
  }
}

class _ReviewsSkeleton extends StatelessWidget {
  const _ReviewsSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = scheme.surfaceContainerHighest.withValues(alpha: 0.7);

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: block,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [bar(120, 12), const SizedBox(height: 8), bar(80, 10)],
                ),
              ],
            ),
            const SizedBox(height: 14),
            bar(double.infinity, 10),
            const SizedBox(height: 6),
            bar(180, 10),
          ],
        ),
      ),
    );
  }
}