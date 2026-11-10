import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/categories/domain/entities/category.dart';
import 'package:booking_app/features/categories/presentation/cubit/category_cubit.dart';
import 'package:booking_app/features/categories/presentation/cubit/category_state.dart';
import 'package:booking_app/features/categories/presentation/widgets/category_card.dart';
import 'package:booking_app/features/services/presentation/screens/services_screen.dart';
import 'package:booking_app/features/categories/presentation/widgets/failure_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/category_view.dart';
part '../widgets/category_grid.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..fetchCategories(),
      child: const _CategoryView(),
    );
  }
}
