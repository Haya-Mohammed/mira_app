part of '../screens/service_details_screen.dart';

class _BookBar extends StatelessWidget {
  const _BookBar({required this.price, required this.onBook});
  final String? price;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  if (price != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.text.price,
                          style: context.textTheme.bodySmall,
                        ),
                        Text(
                          price!,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                  ],
                  Expanded(
                    child: AppButton(
                      label: context.text.bookNow,
                      onPressed: onBook,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
