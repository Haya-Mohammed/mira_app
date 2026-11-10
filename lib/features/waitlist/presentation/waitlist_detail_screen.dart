import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_error_view.dart';
import 'package:booking_app/features/booking/presentation/booking_detail_screen.dart';
import 'package:booking_app/features/waitlist/data/waitlist_data.dart';
import 'package:booking_app/features/waitlist/presentation/waitlist_widgets.dart';
import 'package:flutter/material.dart';

class WaitlistDetailScreen extends StatefulWidget {
  const WaitlistDetailScreen({super.key, required this.entryId, this.initial});
  final int entryId;
  final WaitlistEntry? initial;

  @override
  State<WaitlistDetailScreen> createState() => _WaitlistDetailScreenState();
}

class _WaitlistDetailScreenState extends State<WaitlistDetailScreen> {
  final _source = sl<WaitlistRemoteDatasource>();
  WaitlistEntry? _entry;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.initial;
    _reload();
  }

  String _message(Object error) => error is AppException && error.message?.isNotEmpty == true
      ? error.message!
      : context.text.somethingWentWrong;

  Future<void> _reload({bool preserveError = false}) async {
    try {
      final entry = await _source.get(widget.entryId);
      if (mounted) {
        setState(() {
          _entry = entry;
          if (!preserveError) _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    }
  }

  Future<void> _claim() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _source.claim(widget.entryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.text.waitlistClaimed)));
      await _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _message(error));
      await _reload(preserveError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.text.leaveWaitlist),
        content: Text(context.text.leaveWaitlistConfirmation),
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
      final message = await _source.remove(widget.entryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message ?? context.text.waitlistRemoved)));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = _message(error);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.waitlistDetails),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: entry == null
          ? (_error == null
                ? const Center(child: CircularProgressIndicator())
                : AppErrorView(message: _error!, onRetry: _reload))
          : RefreshIndicator(onRefresh: _reload, child: _buildContent(context, entry)),
      bottomNavigationBar: entry == null ? null : _buildActions(context, entry),
    );
  }

  Widget _buildContent(BuildContext context, WaitlistEntry entry) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Header: status + service name
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WaitlistStatusChip(
                label: entry.statusLabel,
                status: entry.status,
                canClaim: entry.canClaim,
              ),
              const SizedBox(height: 14),
              Text(
                entry.service.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        // Offer banner
        if (entry.offer != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: waitlistOfferColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: waitlistOfferColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: waitlistOfferColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.text.waitlistOffer,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error banner
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: scheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Details
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              WaitlistInfoRow(
                icon: Icons.calendar_today_outlined,
                label: context.text.chooseDay,
                value: waitlistDate(context, entry.date),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: WaitlistInfoRow(
                      icon: Icons.schedule_rounded,
                      label: context.text.waitlistFromTime,
                      value: entry.fromTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WaitlistInfoRow(
                      icon: Icons.schedule_rounded,
                      label: context.text.waitlistToTime,
                      value: entry.toTime,
                    ),
                  ),
                ],
              ),
              if (entry.staff != null) ...[
                const SizedBox(height: 18),
                WaitlistInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: context.text.staff,
                  value: entry.staff!.name,
                ),
              ],
              if (entry.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 18),
                WaitlistInfoRow(
                  icon: Icons.notes_rounded,
                  label: context.text.bookingNotes,
                  value: entry.notes!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Actions live in a pinned bottom bar so they're always reachable,
  /// no matter how long the content is.
  Widget? _buildActions(BuildContext context, WaitlistEntry entry) {
    final canLeave = entry.status == 'waiting' || entry.canClaim;
    final hasBooking = entry.bookingId != null;
    if (!entry.canClaim && !hasBooking && !canLeave) return null;

    final scheme = Theme.of(context).colorScheme;
    final buttons = <Widget>[
      if (entry.canClaim)
        AppButton(label: context.text.claimOffer, loading: _busy, onPressed: _busy ? null : _claim),
      if (hasBooking)
        AppButton(
          label: context.text.bookingDetails,
          loading: false,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BookingDetailScreen(bookingId: entry.bookingId!),
            ),
          ),
        ),
      if (canLeave)
        AppButton(
          label: context.text.leaveWaitlist,
          loading: _busy && !entry.canClaim,
          onPressed: _busy ? null : _remove,
          variant: AppButtonVariant.danger,
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                buttons[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
