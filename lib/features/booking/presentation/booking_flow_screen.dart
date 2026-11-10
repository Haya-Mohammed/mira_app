import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:booking_app/features/booking/presentation/booking_detail_screen.dart';
import 'package:booking_app/features/booking/presentation/widgets/booking_widget.dart';
import 'package:booking_app/features/services/models/service_model.dart';
import 'package:booking_app/features/waitlist/presentation/join_waitlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key, required this.service, this.currency});
  final ServiceModel service;
  final String? currency;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _source = sl<BookingRemoteDatasource>();
  final _coupon = TextEditingController();
  final _notes = TextEditingController();
  List<AvailabilityDay>? _days;
  List<AvailabilitySlot>? _slots;
  AvailabilityDay? _day;
  AvailabilitySlot? _slot;
  int? _staffId;
  String? _appliedCoupon;
  String? _error;
  String? _couponMessage;
  bool _loadingDays = true;
  bool _loadingSlots = false;
  bool _checkingCoupon = false;
  bool _submitting = false;
  int _slotRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadDays();
  }

  @override
  void dispose() {
    _coupon.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _message(Object error) =>
      error is AppException && error.message?.isNotEmpty == true
      ? error.message!
      : context.text.somethingWentWrong;

  Future<void> _loadDays() async {
    setState(() {
      _loadingDays = true;
      _error = null;
    });
    try {
      final days = await _source.getDays(widget.service.id);
      if (!mounted) return;
      setState(() {
        _days = days;
        _loadingDays = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error);
        _loadingDays = false;
      });
    }
  }

  Future<void> _selectDay(AvailabilityDay day) async {
    final request = ++_slotRequest;
    setState(() {
      _day = day;
      _slot = null;
      _staffId = null;
      _slots = null;
      _loadingSlots = true;
      _error = null;
    });
    try {
      final slots = await _source.getSlots(widget.service.id, day.date);
      if (!mounted || request != _slotRequest) return;
      setState(() {
        _slots = slots;
        _loadingSlots = false;
      });
    } catch (error) {
      if (!mounted || request != _slotRequest) return;
      setState(() {
        _error = _message(error);
        _loadingSlots = false;
      });
    }
  }

  Future<void> _checkCoupon() async {
    final code = _coupon.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _checkingCoupon = true;
      _couponMessage = null;
      _appliedCoupon = null;
    });
    try {
      final result = await _source.checkCoupon(code, widget.service.id);
      if (!mounted) return;
      setState(() {
        _appliedCoupon = code;
        _couponMessage =
            result['message'] as String? ?? context.text.couponApplied;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _couponMessage = _message(error));
    } finally {
      if (mounted) setState(() => _checkingCoupon = false);
    }
  }

  Future<void> _submit() async {
    final slot = _slot;
    if (slot == null || _submitting) return;
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
      _submitting = true;
      _error = null;
    });
    try {
      final booking = await _source.create(
        serviceId: widget.service.id,
        startsAt: slot.startsAt,
        staffId: _staffId,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        couponCode: _appliedCoupon,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              BookingDetailScreen(bookingId: booking.id, initial: booking),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error);
        _submitting = false;
      });
      if (error is ConflictException || error is ValidationException) {
        await _selectDay(_day!);
      }
    }
  }

  Widget _loader() => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(text.bookNow), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            widget.service.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Step 1 - day
          StepTitle(number: 1, title: text.chooseDay),
          const SizedBox(height: 12),
          if (_loadingDays)
            _loader()
          else if (_days == null)
            Center(
              child: TextButton(onPressed: _loadDays, child: Text(text.retry)),
            )
          else if (_days!.isEmpty)
            Text(text.noAvailability)
          else
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days!.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final day = _days![i];
                  final enabled = day.open && day.slotsCount > 0;
                  final selected = _day?.date == day.date;
                  final fg = selected
                      ? scheme.onPrimary
                      : enabled
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.38);
                  return Material(
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selected
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: enabled ? () => _selectDay(day) : null,
                      child: Container(
                        width: 76,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: fg,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Step 2 - time
          if (_day != null) ...[
            const SizedBox(height: 28),
            StepTitle(number: 2, title: text.chooseTime),
            const SizedBox(height: 12),
            if (_loadingSlots)
              _loader()
            else if (_slots == null)
              Center(
                child: TextButton(
                  onPressed: () => _selectDay(_day!),
                  child: Text(text.retry),
                ),
              )
            else if (_slots!.isEmpty)
              Text(text.noAvailability)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in _slots!)
                    ChoiceChip(
                      label: Text(slot.time),
                      showCheckmark: false,
                      selected: _slot?.startsAt == slot.startsAt,
                      onSelected: slot.seatsLeft > 0
                          ? (_) => setState(() {
                              _slot = slot;
                              _staffId = null;
                            })
                          : null,
                    ),
                ],
              ),
          ],

          // Step 3 - details
          if (_slot != null) ...[
            const SizedBox(height: 28),
            StepTitle(number: 3, title: text.bookingNotes),
            const SizedBox(height: 12),
            if (_slot!.staff.isNotEmpty) ...[
              DropdownButtonFormField<int?>(
                initialValue: _staffId,
                decoration: InputDecoration(
                  labelText: text.staff,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(text.anySpecialist),
                  ),
                  for (final staff in _slot!.staff)
                    DropdownMenuItem<int?>(
                      value: staff.id,
                      child: Text(staff.name),
                    ),
                ],
                onChanged: (value) => setState(() => _staffId = value),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: text.bookingNotes,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _coupon,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: text.couponCode,
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      suffixIcon: _appliedCoupon != null
                          ? Icon(Icons.check_circle, color: scheme.primary)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) {
                      if (_appliedCoupon != null) {
                        setState(() => _appliedCoupon = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton.tonal(
                    onPressed: _checkingCoupon ? null : _checkCoupon,
                    child: _checkingCoupon
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(text.applyCoupon),
                  ),
                ),
              ],
            ),
            if (_couponMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  _couponMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _appliedCoupon != null
                        ? scheme.primary
                        : scheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SectionCard(
              child: Row(
                children: [
                  Icon(Icons.payments_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text.payAtPlace)),
                ],
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(_error!),
          ],
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.hourglass_empty_rounded, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => JoinWaitlistScreen(service: widget.service),
                ),
              ),
              label: Text(text.joinWaitlist),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: AppButton(
            label: text.confirmBooking,
            loading: _submitting,
            onPressed: _slot == null ? null : _submit,
          ),
        ),
      ),
    );
  }
}
