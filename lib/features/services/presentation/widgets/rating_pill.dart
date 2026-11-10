part of '../screens/staff_screens.dart';

class _RatingPill extends StatelessWidget {
  const _RatingPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.colors.primaryMuted,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5A623)),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.labelMedium),
      ],
    ),
  );
}
