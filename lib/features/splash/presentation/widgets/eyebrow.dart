part of '../screens/splash_screen.dart';

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 22, height: 1, color: color.withValues(alpha: 0.45)),
        const SizedBox(width: 12),
        Text(
          context.text.splashEyebrow,
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: isArabic ? 0 : 2.4,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 22, height: 1, color: color.withValues(alpha: 0.45)),
      ],
    );
  }
}
