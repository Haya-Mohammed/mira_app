import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/features/booking/presentation/booking_flow_screen.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/home/presentation/widgets/home_heading.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/presentation/cubit/catalog_cubit.dart';
import 'package:booking_app/features/services/presentation/screens/reviews_screen.dart';
import 'package:booking_app/features/services/presentation/screens/staff_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part '../widgets/service_details_view.dart';
part '../widgets/book_bar.dart';
part '../widgets/info_chip.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    this.currency,
  });
  final int serviceId;
  final String? currency;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ResourceCubit<ServiceDetails>(
      () => sl<PlaceCatalogRemoteDatasource>().getService(serviceId),
    )..load(),
    child: _ServiceDetailsView(serviceId: serviceId, currency: currency),
  );
}

String? _formatPrice(BuildContext context, dynamic service, String? currency) {
  final amount = service.finalPrice ?? service.salePrice ?? service.price;
  if (amount == null) return null;
  return '${NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(amount)} ${currency ?? ''}'
      .trim();
}
