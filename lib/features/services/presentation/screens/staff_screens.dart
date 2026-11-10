import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/home/data/models/staff_model.dart';
import 'package:booking_app/features/home/presentation/widgets/home_heading.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:booking_app/features/services/presentation/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/staff_card.dart';
part '../widgets/rating_pill.dart';
part '../widgets/portrait.dart';
part '../widgets/initials.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ResourceCubit<List<StaffModel>>(
      sl<PlaceCatalogRemoteDatasource>().getStaff,
    )..load(),
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.text.staff),
        scrolledUnderElevation: 0,
      ),
      body:
          BlocBuilder<
            ResourceCubit<List<StaffModel>>,
            ResourceState<List<StaffModel>>
          >(
            builder: (context, state) {
              if (state is ResourceLoading<List<StaffModel>>) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ResourceError<List<StaffModel>>) {
                return AppErrorView(
                  message: state.failure.localized(context),
                  onRetry: context.read<ResourceCubit<List<StaffModel>>>().load,
                );
              }
              final staff =
                  (state as ResourceLoaded<List<StaffModel>>).data
                      .where((person) => person.isActive)
                      .toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
              if (staff.isEmpty) {
                return AppEmptyView(
                  icon: Icons.people_outline,
                  title: context.text.noStaff,
                  subtitle: context.text.staff,
                );
              }
              return RefreshIndicator(
                onRefresh: context.read<ResourceCubit<List<StaffModel>>>().load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  itemCount: staff.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _StaffCard(staff[index]),
                ),
              );
            },
          ),
    ),
  );
}

class StaffDetailsScreen extends StatelessWidget {
  const StaffDetailsScreen({super.key, required this.staffId});
  final int staffId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ResourceCubit<StaffDetails>(
      () => sl<PlaceCatalogRemoteDatasource>().getStaffMember(staffId),
    )..load(),
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.text.staff),
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<ResourceCubit<StaffDetails>, ResourceState<StaffDetails>>(
        builder: (context, state) {
          if (state is ResourceLoading<StaffDetails>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ResourceError<StaffDetails>) {
            return AppErrorView(
              message: state.failure.localized(context),
              onRetry: context.read<ResourceCubit<StaffDetails>>().load,
            );
          }
          final colors = context.colors;
          final details = (state as ResourceLoaded<StaffDetails>).data;
          final person = details.staff;
          final hasRating = person.rating != null && person.rating!.count > 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _Portrait(person, size: 112, ring: true)),
                      const SizedBox(height: 18),
                      Text(
                        person.name,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineLarge,
                      ),
                      if (person.title != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          person.title!,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge,
                        ),
                      ],
                      if (hasRating) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: _RatingPill(
                            '${person.rating!.average.toStringAsFixed(1)} (${person.rating!.count})',
                          ),
                        ),
                      ],
                      if (person.bio?.isNotEmpty == true) ...[
                        const SizedBox(height: 24),
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            person.bio!,
                            style: context.textTheme.bodyLarge?.copyWith(
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      if (details.services.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        HomeHeading(title: context.text.services),
                        const SizedBox(height: 14),
                        for (final service in details.services)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ServiceDetailsScreen(
                                    serviceId: service.id,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colors.primaryMuted,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      Icons.spa_outlined,
                                      size: 20,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      service.name,
                                      style: context.textTheme.titleMedium,
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
                      if (person.hours.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        HomeHeading(title: context.text.openingHours),
                        const SizedBox(height: 14),
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              for (final hours in person.hours) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                                if (hours != person.hours.last)
                                  Divider(height: 1, color: colors.border),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
