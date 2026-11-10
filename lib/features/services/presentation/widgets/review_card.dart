part of '../screens/reviews_screen.dart';

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.review);
  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author = _reviewerName(review);
    final body = _firstString(review, const ['comment', 'body', 'text']);
    final rating = review['rating'] is String
        ? num.tryParse(review['rating'] as String)
        : review['rating'];
    final date = _formatDate(review['created_at'] ?? review['date']);
    final hasRating = rating is num && rating > 0;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primaryMuted,
                child: author != null
                    ? Text(
                        author.characters.first.toUpperCase(),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Icon(Icons.person_rounded, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    if (hasRating) ...[
                      if (author != null) const SizedBox(height: 4),
                      Row(
                        children: [
                          _Stars(rating: rating.toDouble()),
                          const SizedBox(width: 6),
                          Text(
                            rating.toStringAsFixed(rating % 1 == 0 ? 0 : 1),
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (date != null)
                Text(
                  date,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(body, style: context.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}

String? _firstString(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

/// Finds the reviewer's name whether the API sends it flat
/// (`customer_name`), split (`first_name` + `last_name`), or nested inside a
/// `customer` / `user` / `reviewer` object.
String? _reviewerName(Map<String, dynamic> review) {
  String? fromMap(Map<dynamic, dynamic> map) {
    final direct = _firstString(map, const [
      'customer_name',
      'user_name',
      'reviewer_name',
      'client_name',
      'author_name',
      'full_name',
      'name',
    ]);
    if (direct != null) return direct;
    final first = _firstString(map, const ['first_name']);
    final last = _firstString(map, const ['last_name']);
    final joined = [first, last].whereType<String>().join(' ').trim();
    return joined.isEmpty ? null : joined;
  }

  final flat = fromMap(review);
  if (flat != null) return flat;

  for (final key in const ['customer', 'user', 'reviewer', 'client', 'author']) {
    final value = review[key];
    if (value is Map) {
      final nested = fromMap(value);
      if (nested != null) return nested;
    } else if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _formatDate(dynamic raw) {
  if (raw == null) return null;
  final date = DateTime.tryParse(raw.toString())?.toLocal();
  if (date == null) return null;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
