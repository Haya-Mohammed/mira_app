part of '../screens/busy_hours_screen.dart';

class _HourCell extends StatelessWidget {
  const _HourCell(this.hour);
  final BusyHour? hour;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final level = hour?.level;
    final label = hour?.open != true
        ? context.text.closedAtHour
        : level == null
        ? context.text.busyHours
        : level < .34
        ? context.text.quiet
        : level < .67
        ? context.text.moderate
        : context.text.busy;
    final color = hour?.open != true
        ? colors.disabledBg
        : level == null
        ? colors.surfaceMuted
        : level < .34
        ? colors.success.bg
        : level < .67
        ? colors.warning.bg
        : colors.error.bg;
    // The color carries the meaning; the label stays for screen readers.
    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
