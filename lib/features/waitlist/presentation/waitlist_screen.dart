import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_empty_view.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/waitlist/data/waitlist_data.dart';
import 'package:booking_app/features/waitlist/presentation/waitlist_detail_screen.dart';
import 'package:flutter/material.dart';

const _offerColor = Color(0xFF1E8E5A);

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final _source = sl<WaitlistRemoteDatasource>();
  final _scroll = ScrollController();
  WaitlistPage? _page;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  int _request = 0;

  bool get _hasMore => _page != null && _page!.page < _page!.lastPage;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Infinite scroll: fetch the next page shortly before the end.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 320 &&
        _hasMore &&
        !_loadingMore &&
        !_loading &&
        _error == null) {
      _load(more: true);
    }
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || !_hasMore)) return;
    final request = ++_request;
    final initial = _page == null;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loadingMore = false;
        // Full skeleton only on the very first load; refreshes keep the
        // list on screen.
        if (initial) _loading = true;
      }
      _error = null;
    });
    try {
      final page = await _source.list(page: more ? _page!.page + 1 : 1);
      if (!mounted || request != _request) return;
      setState(() {
        _page = more
            ? WaitlistPage(
          [..._page!.items, ...page.items],
          page.page,
          page.lastPage,
        )
            : page;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = error is AppException && error.message?.isNotEmpty == true
            ? error.message
            : context.text.somethingWentWrong;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _open(WaitlistEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            WaitlistDetailScreen(entryId: entry.id, initial: entry),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.text.myWaitlist),
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    body: _buildBody(context),
  );

  Widget _buildBody(BuildContext context) {
    if (_loading && _page == null) return const _ListSkeleton();

    if (_error != null && _page == null) {
      return AppErrorView(message: _error!, onRetry: _load);
    }

    final raw = _page?.items ?? const <WaitlistEntry>[];
    if (raw.isEmpty) {
      return AppEmptyView(
        icon: Icons.hourglass_empty_rounded,
        title: context.text.noWaitlistEntries,
        subtitle: context.text.myWaitlist,
      );
    }

    // Claimable offers are time-sensitive, so they go first.
    final items = [
      ...raw.where((e) => e.canClaim),
      ...raw.where((e) => !e.canClaim),
    ];
    final hasFooter = _hasMore || _loadingMore || _error != null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: items.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index < items.length) {
            final entry = items[index];
            return _WaitlistCard(entry: entry, onTap: () => _open(entry));
          }
          return _buildFooter(context);
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: () => _load(more: _page != null),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(_error!),
        ),
      );
    }
    return Center(
      child: TextButton(
        onPressed: () => _load(more: true),
        child: Text(context.text.loadMore),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry card
// ---------------------------------------------------------------------------

String _formatDate(BuildContext context, String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return MaterialLocalizations.of(context).formatMediumDate(parsed);
}

class _WaitlistCard extends StatelessWidget {
  const _WaitlistCard({required this.entry, required this.onTap});

  final WaitlistEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.colors;
    final offer = entry.canClaim;

    // AppCard supplies the app's own surface, border and radius. A
    // transparent Material inside it gives InkWell somewhere to paint the
    // ripple, clipped to the card's rounded corners.
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offer banner — only when the user can claim a slot.
              if (offer)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: _offerColor.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        size: 18,
                        color: _offerColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.text.waitlistOffer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _offerColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.primaryMuted,
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            size: 22,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.service.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Date + time block
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Meta(
                              icon: Icons.calendar_today_outlined,
                              text: _formatDate(context, entry.date),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: scheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Meta(
                              icon: Icons.schedule_rounded,
                              text: '${entry.fromTime} – ${entry.toTime}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusChip(
                      label: entry.statusLabel,
                      status: entry.status,
                      canClaim: offer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.status,
    required this.canClaim,
  });

  final String label;
  final String? status;
  final bool canClaim;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = canClaim
        ? _offerColor
        : status == 'waiting'
        ? scheme.primary
        : scheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = scheme.surfaceContainerHighest.withValues(alpha: 0.7);

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: block,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                bar(150, 14),
              ],
            ),
            const SizedBox(height: 16),
            bar(double.infinity, 36),
            const SizedBox(height: 12),
            bar(90, 22),
          ],
        ),
      ),
    );
  }
}