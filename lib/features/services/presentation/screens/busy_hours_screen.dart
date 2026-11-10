import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/home/presentation/widgets/home_heading.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/hour_cell.dart';
part '../widgets/legend_item.dart';

class BusyHoursScreen extends StatelessWidget {
  const BusyHoursScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ResourceCubit<BusyHours>(
      sl<PlaceCatalogRemoteDatasource>().getBusyHours,
    )..load(),
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.text.busyHours),
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<ResourceCubit<BusyHours>, ResourceState<BusyHours>>(
        builder: (context, state) {
          if (state is ResourceLoading<BusyHours>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ResourceError<BusyHours>) {
            return AppErrorView(
              message: state.failure.localized(context),
              onRetry: context.read<ResourceCubit<BusyHours>>().load,
            );
          }
          final data = (state as ResourceLoaded<BusyHours>).data;
          if (data.grid.isEmpty) {
            return AppEmptyView(
              icon: Icons.schedule_outlined,
              title: context.text.noBusyHours,
              subtitle: context.text.busyHoursNote,
            );
          }
          final colors = context.colors;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primaryMuted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 22,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.text.busyHoursNote,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data.now?.label.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    data.now!.label,
                                    style: context.textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Table(
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                defaultColumnWidth: const FixedColumnWidth(54),
                                columnWidths: const {0: FixedColumnWidth(88)},
                                children: [
                                  TableRow(
                                    children: [
                                      const SizedBox.shrink(),
                                      for (
                                        var hour = data.fromHour;
                                        hour <= data.toHour;
                                        hour++
                                      )
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            '${hour.toString().padLeft(2, '0')}:00',
                                            textAlign: TextAlign.center,
                                            style: context.textTheme.labelSmall,
                                          ),
                                        ),
                                    ],
                                  ),
                                  for (final day in data.grid)
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                end: 8,
                                              ),
                                          child: Text(
                                            day.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.textTheme.titleSmall,
                                          ),
                                        ),
                                        for (
                                          var hour = data.fromHour;
                                          hour <= data.toHour;
                                          hour++
                                        )
                                          _HourCell(
                                            day.hours
                                                .where(
                                                  (slot) => slot.hour == hour,
                                                )
                                                .firstOrNull,
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _LegendItem(
                                  color: colors.success.bg,
                                  label: context.text.quiet,
                                ),
                                _LegendItem(
                                  color: colors.warning.bg,
                                  label: context.text.moderate,
                                ),
                                _LegendItem(
                                  color: colors.error.bg,
                                  label: context.text.busy,
                                ),
                                _LegendItem(
                                  color: colors.disabledBg,
                                  label: context.text.closedAtHour,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (data.bestTimes.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        HomeHeading(title: context.text.bestTimes),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final time in data.bestTimes)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.success.bg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 16,
                                      color: colors.success.text,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${time.label} · ${time.time}',
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                            color: colors.success.text,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
