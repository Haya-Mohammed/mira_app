import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:booking_app/features/booking/presentation/widgets/booking_widget.dart';
import 'package:flutter/material.dart';

part 'widgets/reference.dart';
part 'widgets/timeline_step.dart';
part 'widgets/reschedule_sheet.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId, this.initial});
  final int bookingId;
  final BookingRecord? initial;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _source = sl<BookingRemoteDatasource>();
  BookingRecord? _booking;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.initial;
    _reload();
  }

  String _message(Object error) =>
      error is AppException && error.message?.isNotEmpty == true
      ? error.message!
      : context.text.somethingWentWrong;

  Future<void> _reload() async {
    try {
      final booking = await _source.getBooking(widget.bookingId);
      if (mounted) {
        setState(() {
          _booking = booking;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    }
  }

  Future<void> _cancel() async {
    final reason = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.text.cancelBooking),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_booking!.cancelIsLate) ...[
              ErrorBanner(context.text.lateCancellation),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: reason,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.text.cancellationReason,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
    if (confirm != true || !mounted) {
      reason.dispose();
      return;
    }
    final value = reason.text.trim();
    reason.dispose();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final booking = await _source.cancel(
        widget.bookingId,
        reason: value.isEmpty ? null : value,
      );
      if (mounted) setState(() => _booking = booking);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review() async {
    final comment = TextEditingController();
    int rating = 5;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(context.text.reviewBooking),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 32,
                      color: Colors.amber.shade700,
                      icon: Icon(
                        i <= rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                      ),
                      onPressed: () => update(() => rating = i),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.text.reviewComment,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
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
      ),
    );
    if (confirmed != true || !mounted) {
      comment.dispose();
      return;
    }
    final value = comment.text.trim();
    comment.dispose();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _source.review(
        widget.bookingId,
        rating,
        comment: value.isEmpty ? null : value,
      );
      await _reload();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reschedule() async {
    final booking = _booking!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final days = await _source.getDays(booking.serviceId);
      if (!mounted) return;
      setState(() => _busy = false);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => _RescheduleSheet(
          source: _source,
          booking: booking,
          days: days,
          onUpdated: (updated) {
            Navigator.pop(sheetContext);
            setState(() => _booking = updated);
          },
        ),
      );
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
    final booking = _booking;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasActions =
        booking != null &&
        (booking.canCancel || booking.canReschedule || booking.canReview);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.bookingDetails),
        centerTitle: false,
      ),
      body: booking == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : TextButton(onPressed: _reload, child: Text(_error!)),
            )
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Summary header
                  SectionCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DateTile(
                              dayLabel: booking.dayLabel,
                              date: booking.date,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.serviceName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${booking.date} · ${booking.time}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        StatusPill(booking.statusLabel),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: _Reference(
                                label: context.text.bookingNumber,
                                value: booking.number,
                              ),
                            ),
                            Expanded(
                              child: _Reference(
                                label: context.text.bookingCode,
                                value: booking.code,
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details
                  SectionCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        if (booking.staffName != null)
                          InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: context.text.staff,
                            value: booking.staffName!,
                          ),
                        if (booking.total != null)
                          InfoRow(
                            icon: Icons.sell_outlined,
                            label: context.text.price,
                            value: '${booking.total} ${booking.currencySymbol}',
                          ),
                        if (booking.paymentMethodLabel.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.payments_outlined,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(booking.paymentMethodLabel),
                                ),
                              ],
                            ),
                          ),
                        if (booking.cancelReason != null)
                          InfoRow(
                            icon: Icons.cancel_outlined,
                            label: context.text.cancellationReason,
                            value: booking.cancelReason!,
                          ),
                      ],
                    ),
                  ),

                  // Timeline
                  if (booking.timeline.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < booking.timeline.length; i++)
                            _TimelineStep(
                              step: booking.timeline[i],
                              isLast: i == booking.timeline.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorBanner(_error!),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: hasActions
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (booking.canReview)
                      AppButton(
                        label: context.text.reviewBooking,
                        loading: _busy,
                        onPressed: _busy ? null : _review,
                      ),
                    if (booking.canReschedule) ...[
                      if (booking.canReview) const SizedBox(height: 10),
                      AppButton(
                        label: context.text.rescheduleBooking,
                        loading: _busy,
                        onPressed: _busy ? null : _reschedule,
                        variant: AppButtonVariant.secondary,
                      ),
                    ],
                    if (booking.canCancel) ...[
                      if (booking.canReview || booking.canReschedule)
                        const SizedBox(height: 10),
                      AppButton(
                        label: context.text.cancelBooking,
                        loading: _busy,
                        onPressed: _busy ? null : _cancel,
                        variant: AppButtonVariant.danger,
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
