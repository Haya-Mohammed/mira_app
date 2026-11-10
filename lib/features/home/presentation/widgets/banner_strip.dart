import 'dart:ui';

import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class BannerStrip extends StatefulWidget {
  const BannerStrip({super.key, required this.items});
  final List<dynamic> items;

  @override
  State<BannerStrip> createState() => _BannerStripState();
}

class _BannerStripState extends State<BannerStrip> {
  static const _viewportFraction = .92;
  static const _gap = 12.0;

  /// Width / height of a banner card. 2:1 is the common banner ratio, so
  /// properly sized banners fill the card with no cropping at all.
  static const _aspectRatio = 2.0;

  final _controller = PageController(viewportFraction: _viewportFraction);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = widget.items.length;
    return Column(
      children: [
        // Height follows the width, so the card keeps the same shape on
        // every screen size instead of using a fixed 170 px height.
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth * _viewportFraction - _gap;
            return SizedBox(
              height: cardWidth / _aspectRatio,
              child: PageView.builder(
                controller: _controller,
                itemCount: count,
                padEnds: false,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final item = widget.items[i];
                  final map = item is Map ? item : const {};
                  final image = map['image'] ?? map['image_url'] ?? map['url'];
                  final title = map['title'] ?? map['name'];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: _gap),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _BannerImage(url: image is String ? image : null),
                          if (title is String && title.isNotEmpty) ...[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: .7)],
                                  stops: const [.35, 1],
                                ),
                              ),
                            ),
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              start: 18,
                              end: 18,
                              bottom: 16,
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (count > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index ? colors.primary : colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Shows the whole banner image (BoxFit.contain) so nothing is zoomed or
/// cropped. If the image's ratio differs from the card, the empty space is
/// filled with a blurred copy of the same image instead of bare bars.
class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = ColoredBox(
      color: colors.border.withValues(alpha: .35),
      child: Center(child: Icon(Icons.local_offer_outlined, color: colors.border)),
    );

    final src = url;
    if (src == null || src.isEmpty) return placeholder;

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Image.network(src, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
        ),
        // Sharp, uncropped image on top.
        Image.network(
          src,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : const SizedBox.shrink(),
          errorBuilder: (_, _, _) => placeholder,
        ),
      ],
    );
  }
}
