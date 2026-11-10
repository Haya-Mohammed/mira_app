import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/services/models/service_model.dart';
import 'package:booking_app/features/waitlist/data/waitlist_data.dart';
import 'package:booking_app/features/waitlist/presentation/waitlist_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinWaitlistScreen extends StatefulWidget {
  const JoinWaitlistScreen({super.key, required this.service});
  final ServiceModel service;

  @override
  State<JoinWaitlistScreen> createState() => _JoinWaitlistScreenState();
}

class _JoinWaitlistScreenState extends State<JoinWaitlistScreen> {
  final _source = sl<WaitlistRemoteDatasource>();
  final _notes = TextEditingController();
  DateTime? _date;
  TimeOfDay? _from;
  TimeOfDay? _to;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _rangeInvalid =>
      _from != null &&
      _to != null &&
      _to!.hour * 60 + _to!.minute <= _from!.hour * 60 + _from!.minute;

  bool get _canSubmit => _date != null && _from != null && _to != null && !_rangeInvalid && !_busy;

  String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _timeValue(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  // Localized display values (the API values above stay untouched).
  String? _dateLabel() =>
      _date == null ? null : MaterialLocalizations.of(context).formatMediumDate(_date!);

  String? _timeLabel(TimeOfDay? time) => time == null
      ? null
      : MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(time, alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() {
        _date = date;
        _error = null;
      });
    }
  }

  Future<void> _pickTime({required bool from}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: from
          ? _from ?? const TimeOfDay(hour: 9, minute: 0)
          : _to ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (time != null && mounted) {
      setState(() {
        _error = null;
        if (from) {
          _from = time;
        } else {
          _to = time;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (context.read<UserCubit>().state.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.text.signInToBook),
          action: SnackBarAction(
            label: context.text.login,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final entry = await _source.create(
        serviceId: widget.service.id,
        date: _dateValue(_date!),
        fromTime: _timeValue(_from!),
        toTime: _timeValue(_to!),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => WaitlistDetailScreen(entryId: entry.id, initial: entry),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AppException && error.message?.isNotEmpty == true
            ? error.message
            : context.text.somethingWentWrong;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.joinWaitlist),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Service header
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                  child: Icon(Icons.hourglass_top_rounded, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.text.waitlistDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date
          _PickerTile(
            icon: Icons.calendar_today_outlined,
            label: context.text.chooseDay,
            placeholder: context.text.waitlistSelectDate,
            value: _dateLabel(),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),

          // Time window
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.schedule_rounded,
                  label: context.text.waitlistFromTime,
                  placeholder: context.text.chooseTime,
                  value: _timeLabel(_from),
                  onTap: () => _pickTime(from: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  icon: Icons.schedule_rounded,
                  label: context.text.waitlistToTime,
                  placeholder: context.text.chooseTime,
                  value: _timeLabel(_to),
                  hasError: _rangeInvalid,
                  onTap: () => _pickTime(from: false),
                ),
              ),
            ],
          ),
          if (_rangeInvalid)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 16, color: scheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.text.waitlistTimeError,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notes,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: context.text.bookingNotes,
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          // Server / submit error
          if (_error != null) ...[
            const SizedBox(height: 16),
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
        ],
      ),
      // Pinned submit button, stays above the keyboard.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: AppButton(
            label: context.text.joinWaitlist,
            loading: _busy,
            onPressed: _canSubmit ? _submit : null,
          ),
        ),
      ),
    );
  }
}

/// A tappable "field" that shows a label and either the chosen value or a
/// placeholder. Highlights once a value is picked.
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.hasError = false,
  });

  final IconData icon;
  final String label;
  final String placeholder;
  final String? value;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = value != null;

    final borderColor = hasError
        ? scheme.error
        : selected
        ? scheme.primary.withValues(alpha: 0.6)
        : scheme.outlineVariant;

    return Material(
      color: selected ? scheme.primary.withValues(alpha: 0.06) : scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? scheme.primary : scheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(color: scheme.outline),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
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
