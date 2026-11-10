part of '../screens/categories_screen.dart';

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(context.text.categories)),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) => switch (state) {
          CategoryInitial() ||
          CategoryLoading() => const Center(child: CircularProgressIndicator()),
          CategoryError(:final failure) => AppErrorView(
            message: failure.localized(context),
            onRetry: cubit.fetchCategories,
          ),
          CategoryEmpty() => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: c.maxHeight,
                  child: AppEmptyView(
                    icon: Icons.category_outlined,
                    title: context.text.noCategories,
                    subtitle: context.text.noCategoriesHint,
                  ),
                ),
              ),
            ),
          ),
          CategoryLoaded(:final categories) => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: _CategoryGrid(categories: categories),
          ),
        },
      ),
    );
  }
}
