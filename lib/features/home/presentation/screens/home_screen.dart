import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/core/widgets/app_logo.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:booking_app/features/home/presentation/cubit/home_state.dart';
import 'package:booking_app/features/home/presentation/widgets/home_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 38),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                context.text.appTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() ||
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeError(:final failure) => AppErrorView(
            message: failure.localized(context),
            onRetry: cubit.fetchHome,
          ),
          HomeLoaded(:final data) => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: HomeContent(data: data),
          ),
        },
      ),
    );
  }
}
