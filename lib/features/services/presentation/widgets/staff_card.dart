part of '../screens/staff_screens.dart';

class _StaffCard extends StatelessWidget {
  const _StaffCard(this.person);
  final StaffModel person;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasRating = person.rating != null && person.rating!.count > 0;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => StaffDetailsScreen(staffId: person.id),
        ),
      ),
      child: Row(
        children: [
          _Portrait(person, size: 64, ring: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium,
                ),
                if (person.title != null)
                  Text(
                    person.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                if (hasRating) ...[
                  const SizedBox(height: 6),
                  _RatingPill(
                    '${person.rating!.average.toStringAsFixed(1)} (${person.rating!.count})',
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
        ],
      ),
    );
  }
}
