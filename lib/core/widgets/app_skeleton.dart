import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/spacing.dart';
import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child, this.label});

  final Widget child;
  final String? label;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _opacity = Tween<double>(
    begin: .62,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: widget.label ?? context.text.loading,
    liveRegion: true,
    child: ExcludeSemantics(
      child: FadeTransition(opacity: _opacity, child: widget.child),
    ),
  );
}

class AppSkeletonBlock extends StatelessWidget {
  const AppSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.circular = false,
    this.pill = false,
  });

  final double? width;
  final double height;
  final bool circular;
  final bool pill;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.colors.surfaceMuted,
      shape: circular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circular
          ? null
          : BorderRadius.circular(
              pill ? context.radius.pill : context.radius.sm,
            ),
    ),
  );
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: context.radius.lgAll,
      border: Border.all(color: context.colors.border),
    ),
    child: child,
  );
}
