part of '../bookings_screen.dart';

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});
  final BookingRecord booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.textTheme;
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : MaterialLocalizations.of(context).formatMediumDate(date);
    final number = booking.number.isNotEmpty ? booking.number : booking.code;
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceName,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _BookingStatus(booking: booking),
            ],
          ),
          const SizedBox(height: 12),
          _BookingMeta(
            Icons.calendar_today_outlined,
            '$dateLabel · ${booking.time}',
          ),
          if (booking.staffName?.isNotEmpty == true) ...[
            const SizedBox(height: 5),
            _BookingMeta(Icons.person_outline_rounded, booking.staffName!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (number.isNotEmpty)
                Text(
                  '#$number',
                  style: theme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              const Spacer(),
              Text(
                context.text.bookingDetails,
                style: theme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 17,
                color: colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingMeta extends StatelessWidget {
  const _BookingMeta(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: context.colors.primary),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    ],
  );
}

class _BookingStatus extends StatelessWidget {
  const _BookingStatus({required this.booking});
  final BookingRecord booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = switch (booking.status.toLowerCase()) {
      'confirmed' => colors.success,
      'completed' => colors.info,
      'cancelled' || 'canceled' || 'no_show' => colors.error,
      _ => colors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: status.text),
          const SizedBox(width: 5),
          Text(
            booking.statusLabel.isNotEmpty
                ? booking.statusLabel
                : booking.status,
            style: context.textTheme.labelSmall?.copyWith(
              color: status.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
