import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/features/notifications/data/notifications_remote_datasource.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _source = sl<NotificationsRemoteDatasource>();
  final _scrollController = ScrollController();
  NotificationsPage? _page;
  final _items = <Map<String, dynamic>>[];
  String? _error;
  bool _loading = false;
  bool _reading = false;

  bool get _hasMore => _page != null && _page!.page < _page!.lastPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Infinite scroll: fetch the next page shortly before reaching the end.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240 &&
        _hasMore &&
        !_loading &&
        _error == null) {
      _load(more: true);
    }
  }

  String _messageFor(Object error) =>
      error is AppException && error.message?.isNotEmpty == true
          ? error.message!
          : context.text.somethingWentWrong;

  Future<void> _load({bool more = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _source.getNotifications(
        page: more ? (_page?.page ?? 0) + 1 : 1,
      );
      if (!mounted) return;
      setState(() {
        if (!more) _items.clear();
        _items.addAll(page.items);
        _page = page;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _readAll() async {
    if (_reading) return;
    setState(() => _reading = true);
    try {
      await _source.readAll();
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = _page?.unread ?? 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.text.notifications),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton.icon(
                onPressed: _reading ? null : _readAll,
                icon: _reading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.done_all_rounded, size: 20),
                label: Text(context.text.markAllRead),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // First load: skeleton placeholders instead of a lone spinner.
    if (_loading && _page == null) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _SkeletonTile(),
      );
    }

    // Failed first load / empty list: full-height states so pull-to-refresh
    // still works.
    if (_items.isEmpty) {
      return _CenteredState(
        icon: _error != null
            ? Icons.cloud_off_rounded
            : Icons.notifications_none_rounded,
        message: _error ?? context.text.noNotifications,
        onRetry: _error != null ? _load : null,
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _items.length) return _buildFooter(context);
        return _NotificationTile(item: _items[index]);
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_loading) {
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
    if (_hasMore) {
      return Center(
        child: TextButton(
          onPressed: () => _load(more: true),
          child: Text(context.text.loadMore),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}

// ---------------------------------------------------------------------------
// Notification tile
// ---------------------------------------------------------------------------

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final unread = _isUnread(item);
    final title = (item['title'] ?? context.text.notifications).toString();
    final body = (item['body'] ?? item['message'])?.toString();
    final reviewer = _reviewerName(item);
    final rating = _rating(item);
    final time = _formatDate(item['created_at']);
    final kind = _kindOf(item);

    return Container(
      decoration: BoxDecoration(
        color: unread
            ? scheme.primary.withValues(alpha: 0.06)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unread
              ? scheme.primary.withValues(alpha: 0.28)
              : scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(kind.icon, color: scheme.onPrimaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (unread)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 8,
                          top: 5,
                        ),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                if (reviewer != null) ...[
                  const SizedBox(height: 6),
                  _ReviewerChip(name: reviewer, rating: rating),
                ],
                if (body != null && body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (time != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewerChip extends StatelessWidget {
  const _ReviewerChip({required this.name, this.rating});

  final String name;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 9,
                backgroundColor: scheme.secondary,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (rating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5B301)),
              const SizedBox(width: 2),
              Text(
                rating!.toStringAsFixed(rating! % 1 == 0 ? 0 : 1),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: scheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 16),
                      FilledButton.tonalIcon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Icon(Icons.more_horiz_rounded),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: block, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(150, 12),
                const SizedBox(height: 10),
                bar(double.infinity, 10),
                const SizedBox(height: 6),
                bar(100, 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers — defensive parsing, since the payload is a loose Map.
// ---------------------------------------------------------------------------

({IconData icon}) _kindOf(Map<String, dynamic> item) {
  final type = (item['type'] ?? '').toString().toLowerCase();
  if (type.contains('review') || _rating(item) != null) {
    return (icon: Icons.star_rounded);
  }
  if (type.contains('booking') || type.contains('appointment')) {
    return (icon: Icons.event_available_rounded);
  }
  if (type.contains('payment')) return (icon: Icons.payments_rounded);
  return (icon: Icons.notifications_rounded);
}

bool _isUnread(Map<String, dynamic> item) {
  if (item.containsKey('read_at')) return item['read_at'] == null;
  final flag = item['is_read'] ?? item['read'];
  if (flag == null) return false;
  return !(flag == true || flag == 1 || flag == '1');
}

/// Looks for the reviewer's name in the common shapes an API might return:
/// flat keys, a nested `reviewer`/`user`/`customer` object, or the same
/// inside a `data` payload.
String? _reviewerName(Map<String, dynamic> item) {
  String? pick(Map<String, dynamic>? map) {
    if (map == null) return null;
    for (final key in const [
      'reviewer_name',
      'reviewerName',
      'user_name',
      'customer_name',
      'client_name',
    ]) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    for (final key in const ['reviewer', 'user', 'customer', 'client']) {
      final value = map[key];
      if (value is Map && value['name'] is String) {
        final name = (value['name'] as String).trim();
        if (name.isNotEmpty) return name;
      }
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  final data = item['data'];
  return pick(item) ?? pick(data is Map<String, dynamic> ? data : null);
}

double? _rating(Map<String, dynamic> item) {
  final data = item['data'];
  final raw = item['rating'] ?? (data is Map ? data['rating'] : null);
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw);
  return null;
}

String? _formatDate(dynamic raw) {
  if (raw == null) return null;
  final date = DateTime.tryParse(raw.toString())?.toLocal();
  if (date == null) return null;

  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return '•';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}