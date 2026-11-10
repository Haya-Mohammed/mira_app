import 'dart:async';
import 'dart:math' as math;

import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

part '../widgets/eyebrow.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;
  Timer? _navigationTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _entrance = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }

    _navigationTimer = Timer(
      Duration(milliseconds: reduceMotion ? 350 : 1900),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.background,
              Color.lerp(colors.background, colors.primaryMuted, 0.48)!,
              colors.background,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _SalonLinesPainter(
                color: colors.primary.withValues(
                  alpha: context.isDark ? 0.13 : 0.10,
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Eyebrow(color: colors.primary),
                          FadeTransition(
                            opacity: _entrance,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.10),
                                end: Offset.zero,
                              ).animate(_entrance),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppLogo(size: 196),
                                  const SizedBox(height: 34),
                                  Text(
                                    context.text.appTitle,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.displayLarge
                                        ?.copyWith(
                                          fontFamily: isArabic
                                              ? null
                                              : 'Georgia',
                                          fontSize: isArabic ? 42 : 48,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: isArabic ? 0 : 6,
                                          color: colors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: 38,
                                    height: 1,
                                    color: colors.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.text.splashTagline,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: colors.textSecondary,
                                          letterSpacing: isArabic ? 0 : 0.3,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            label: context.text.splashPreparing,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: colors.primary,
                                    backgroundColor: colors.primaryMuted,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.text.splashPreparing,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colors.textSecondary,
                                    letterSpacing: isArabic ? 0 : 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalonLinesPainter extends CustomPainter {
  const _SalonLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final radius in [160.0, 205.0, 250.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width + 48, -40), radius: radius),
        math.pi * 0.35,
        math.pi * 1.12,
        false,
        paint,
      );
    }
    for (final radius in [155.0, 205.0, 255.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-74, size.height + 46), radius: radius),
        -math.pi * 0.70,
        math.pi * 1.12,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SalonLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}
