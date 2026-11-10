import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final Map review;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author =
        review['customer_name'] ?? review['user_name'] ?? review['name'];
    final body = review['comment'] ?? review['body'] ?? review['text'];
    final rating = review['rating'];
    final hasAuthor = author is String && author.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hasAuthor) ...[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primaryMuted,
                    child: Text(
                      author.characters.first.toUpperCase(),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAuthor)
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall,
                        ),
                      if (rating is num) _Stars(rating: rating.toDouble()),
                    ],
                  ),
                ),
                Icon(
                  Icons.format_quote_rounded,
                  size: 28,
                  color: colors.primary.withValues(alpha: .25),
                ),
              ],
            ),
            if (body is String && body.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
              size: 16,
              color: gold,
            ),
        ],
      ),
    );
  }
}
