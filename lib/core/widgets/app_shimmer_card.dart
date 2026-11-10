import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class AppShimmerCard extends StatefulWidget {
  const AppShimmerCard({super.key, this.height = 152});

  final double height;

  @override
  State<AppShimmerCard> createState() => _AppShimmerCardState();
}

class _AppShimmerCardState extends State<AppShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Container(
        height: widget.height,
        padding: EdgeInsets.all(context.spacing.lg),
        decoration: BoxDecoration(
          color: Color.lerp(
            context.colors.surfaceMuted,
            context.colors.disabledBorder,
            _controller.value,
          ),
          borderRadius: BorderRadius.circular(context.radius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(context, 148, 18),
            SizedBox(height: context.spacing.md),
            _block(context, double.infinity, 12),
            SizedBox(height: context.spacing.sm),
            _block(context, 176, 12),
            const Spacer(),
            Row(
              children: [
                Expanded(child: _block(context, double.infinity, 34)),
                SizedBox(width: context.spacing.sm),
                Expanded(child: _block(context, double.infinity, 34)),
                SizedBox(width: context.spacing.sm),
                Expanded(child: _block(context, double.infinity, 34)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(BuildContext context, double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.colors.surface.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(context.radius.sm),
    ),
  );
}
