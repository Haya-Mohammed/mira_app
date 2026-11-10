part of '../screens/categories_screen.dart';

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.base,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: spacing.lg,
        crossAxisSpacing: spacing.base,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) => CategoryCard(
        category: categories[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ServicesScreen(
              categoryId: categories[i].id,
              categoryName: categories[i].name,
            ),
          ),
        ),
      ),
    );
  }
}
