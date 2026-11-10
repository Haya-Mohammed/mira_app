part of '../booking_detail_screen.dart';

class _RescheduleSheet extends StatefulWidget {
  const _RescheduleSheet({
    required this.source,
    required this.booking,
    required this.days,
    required this.onUpdated,
  });
  final BookingRemoteDatasource source;
  final BookingRecord booking;
  final List<AvailabilityDay> days;
  final ValueChanged<BookingRecord> onUpdated;

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  List<AvailabilitySlot>? _slots;
  AvailabilitySlot? _slot;
  AvailabilityDay? _day;
  int? _staffId;
  String? _error;
  bool _busy = false;

  Future<void> _load(AvailabilityDay day) async {
    setState(() {
      _day = day;
      _slots = null;
      _slot = null;
      _error = null;
      _busy = true;
    });
    try {
      final slots = await widget.source.getSlots(
        widget.booking.serviceId,
        day.date,
      );
      if (mounted) setState(() => _slots = slots);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AppException
              ? error.message
              : context.text.somethingWentWrong,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_slot == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await widget.source.reschedule(
        widget.booking.id,
        _slot!.startsAt,
        staffId: _staffId,
      );
      widget.onUpdated(updated);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AppException
              ? error.message
              : context.text.somethingWentWrong,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.text.rescheduleBooking,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          StepTitle(number: 1, title: context.text.chooseDay),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final day in widget.days)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text('${day.label} ${day.date}'),
                      showCheckmark: false,
                      selected: _day?.date == day.date,
                      onSelected: day.open && day.slotsCount > 0
                          ? (_) => _load(day)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_slots != null) ...[
            const SizedBox(height: 20),
            StepTitle(number: 2, title: context.text.chooseTime),
            const SizedBox(height: 12),
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
          if (_slot != null && _slot!.staff.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _staffId,
              decoration: InputDecoration(
                labelText: context.text.staff,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(context.text.anySpecialist),
                ),
                for (final staff in _slot!.staff)
                  DropdownMenuItem<int?>(
                    value: staff.id,
                    child: Text(staff.name),
                  ),
              ],
              onChanged: (value) => setState(() => _staffId = value),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(_error!),
          ],
          const SizedBox(height: 20),
          AppButton(
            label: context.text.confirm,
            loading: _busy,
            onPressed: _slot == null || _busy ? null : _submit,
          ),
        ],
      ),
    ),
  );
}
