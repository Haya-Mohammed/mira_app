import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/home/data/models/staff_model.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:booking_app/features/services/presentation/screens/service_details_screen.dart';
import 'package:booking_app/features/services/presentation/widgets/catalog_service_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/services_view.dart';
part '../widgets/filter_button.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.staffId,
    this.currency,
  });
  final int? categoryId;
  final String? categoryName;
  final int? staffId;
  final String? currency;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ServicesCubit(
      sl(),
      query: ServiceQuery(categoryId: categoryId, staffId: staffId),
    )..load(),
    child: _ServicesView(categoryName: categoryName, currency: currency),
  );
}

/// Square filter button that shows a dot while any filter is applied.
