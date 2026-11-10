part of '../screens/reviews_screen.dart';

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A623);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - .5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: 17,
              color: gold,
            ),
        ],
      ),
    );
  }
}
