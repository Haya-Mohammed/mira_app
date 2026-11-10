import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/direct/data/queue_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectScreen extends StatefulWidget {
  const DirectScreen({super.key});

  @override
  State<DirectScreen> createState() => _DirectScreenState();
}

class _DirectScreenState extends State<DirectScreen> {
  final _source = sl<QueueRemoteDatasource>();
  QueueStatus? _status;
  QueueTicket? _ticket;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _message(Object error) =>
      error is AppException && error.message?.isNotEmpty == true
      ? error.message!
      : context.text.somethingWentWrong;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await _source.getStatus();
      if (!mounted) return;
      final ticket =
          context.read<UserCubit>().state.status == AuthStatus.authenticated
          ? await _source.getMyTicket()
          : null;
      if (!mounted) return;
      setState(() {
        _status = status;
        _ticket = ticket;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error);
        _loading = false;
      });
    }
  }

  Future<void> _join() async {
    if (context.read<UserCubit>().state.status != AuthStatus.authenticated) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _ticket = await _source.createTicket();
      if (mounted) await _load();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final ticket = _ticket;
    if (ticket == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.text.cancelQueueTicket),
        content: Text(context.text.cancelQueueConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.text.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.text.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _source.cancelTicket(ticket.id);
      if (!mounted) return;
      _ticket = null;
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final colors = context.colors;
    final text = context.text;
    return Scaffold(
      appBar: AppBar(title: Text(text.direct), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: colors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  text.liveQueue,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading && status == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (status == null)
              _NoticeCard(
                message: _error ?? text.somethingWentWrong,
                onRetry: _load,
              )
            else ...[
              _StatusCard(status: status),
              if (_ticket != null) ...[
                const SizedBox(height: 12),
                _TicketCard(ticket: _ticket!, busy: _busy, onCancel: _cancel),
              ] else if (status.enabled && status.open && status.accepting) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _join,
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: Text(text.joinQueue),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: colors.primary,
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text.queueList,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: text.retry,
                    onPressed: _loading || _busy ? null : _load,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (status.nowServing.isEmpty && status.next.isEmpty)
                _NoticeCard(message: text.queueNoEntries)
              else ...[
                for (final entry in status.nowServing)
                  _QueueEntryCard(entry: entry, serving: true),
                for (final entry in status.next)
                  _QueueEntryCard(entry: entry, serving: false),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                _NoticeCard(message: _error!, onRetry: _load),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final QueueStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final active = status.enabled && status.open && status.accepting;
    final stateLabel = !status.enabled
        ? text.queueDisabled
        : !status.open
        ? text.queueClosed
        : !status.accepting
        ? text.queueNotAccepting
        : text.queueAccepting;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Metric(
                value: status.nowServing.isEmpty
                    ? '—'
                    : _entryNumber(status.nowServing.first),
                label: text.queueNowServing,
              ),
              _Metric(
                value: '${status.waitingCount}',
                label: text.queueWaitingCount,
              ),
              _Metric(
                value: '${status.servedToday}',
                label: text.queueServedToday,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              stateLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? colors.success.text : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    ),
  );
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.busy,
    required this.onCancel,
  });
  final QueueTicket ticket;
  final bool busy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryHover]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.myQueueTicket,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.number ?? '#${ticket.id}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ticket.position != null || ticket.status != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    ticket.position != null
                        ? '${text.queuePosition}: ${ticket.position}'
                        : ticket.status!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onPrimary),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: busy ? null : onCancel,
            style: TextButton.styleFrom(foregroundColor: colors.onPrimary),
            child: Text(text.cancelQueueTicket),
          ),
        ],
      ),
    );
  }
}

class _QueueEntryCard extends StatelessWidget {
  const _QueueEntryCard({required this.entry, required this.serving});
  final dynamic entry;
  final bool serving;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: serving ? colors.success.border : colors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _entryNumber(entry),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: serving ? colors.success.bg : colors.warning.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              serving ? text.queueNowServing : text.queueWaitingCount,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: serving ? colors.success.text : colors.warning.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _entryNumber(dynamic entry) {
  if (entry is Map) {
    final value =
        entry['number'] ??
        entry['ticket_number'] ??
        entry['code'] ??
        entry['id'];
    return value?.toString() ?? '—';
  }
  return entry?.toString() ?? '—';
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text(context.text.retry)),
      ],
    ),
  );
}
