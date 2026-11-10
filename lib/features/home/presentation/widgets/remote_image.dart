import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class RemoteImage extends StatelessWidget {
  const RemoteImage({super.key, required this.url, required this.icon});
  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fallback = ColoredBox(
      color: colors.primaryMuted,
      child: Center(
        child: Icon(
          icon,
          color: colors.primary.withValues(alpha: .55),
          size: 32,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return fallback;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}
