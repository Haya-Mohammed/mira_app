part of '../screens/services_screen.dart';

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.tooltip,
    required this.active,
    required this.onPressed,
  });
  final String tooltip;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? colors.primary : colors.primaryMuted,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: active ? Colors.white : colors.primary,
                ),
                if (active)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
