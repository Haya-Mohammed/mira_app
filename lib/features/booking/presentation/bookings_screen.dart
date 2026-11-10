import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/errors/exceptions.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/booking/data/booking_data.dart';
import 'package:booking_app/features/booking/presentation/booking_detail_screen.dart';
import 'package:booking_app/features/booking/presentation/widgets/booking_widget.dart';
import 'package:booking_app/features/services/presentation/screens/services_screen.dart';
import 'package:booking_app/features/waitlist/presentation/waitlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'widgets/booking_card.dart';
part 'widgets/message.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _source = sl<BookingRemoteDatasource>();
  String _scope = 'upcoming';
  BookingPage? _page;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    if (context.read<UserCubit>().state.status == AuthStatus.authenticated) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load({bool more = false}) async {
    if (context.read<UserCubit>().state.status != AuthStatus.authenticated) {
      return;
    }
    if (more && (_page == null || _page!.page >= _page!.lastPage)) return;
    final request = ++_request;
    final scope = _scope;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
      _error = null;
    });
    try {
      final page = await _source.getBookings(
        scope: scope,
        page: more ? _page!.page + 1 : 1,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _page = more
            ? BookingPage(
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
        _error = error is AppException && error.message != null
            ? error.message
            : context.text.somethingWentWrong;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _open(BookingRecord booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailScreen(bookingId: booking.id),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _page = null;
          _load();
        } else {
          ++_request;
          setState(() {
            _page = null;
            _error = null;
            _loading = false;
            _loadingMore = false;
          });
        }
      },
      builder: (context, authState) => _buildScreen(context, authState),
    );
  }

  Widget _buildScreen(BuildContext context, UserState authState) {
    final items = _page?.items ?? const <BookingRecord>[];
    final signedIn = authState.status == AuthStatus.authenticated;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.myBookings),
        centerTitle: true,
        actions: signedIn
            ? [
                IconButton(
                  tooltip: context.text.myWaitlist,
                  icon: const Icon(Icons.hourglass_empty_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const WaitlistScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (signedIn)
            _BookingsTabs(
              scope: _scope,
              onSelected: (scope) {
                if (scope == _scope) return;
                setState(() {
                  _scope = scope;
                  _page = null;
                });
                _load();
              },
            ),
          Expanded(
            child: signedIn
                ? RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null && _page == null)
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .55,
                            child: _Message(
                              icon: Icons.cloud_off_rounded,
                              text: _error!,
                              actionLabel: context.text.retry,
                              onAction: _load,
                            ),
                          )
                        else if (items.isEmpty)
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * .55,
                            child: _Message(
                              icon: Icons.event_available_outlined,
                              text: _scope == 'upcoming'
                                  ? context.text.noUpcomingBookings
                                  : context.text.noPastBookings,
                              actionLabel: _scope == 'upcoming'
                                  ? context.text.bookAppointment
                                  : null,
                              onAction: _scope == 'upcoming'
                                  ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => const ServicesScreen(),
                                      ),
                                    )
                                  : null,
                            ),
                          )
                        else
                          for (final booking in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _BookingCard(
                                booking: booking,
                                onTap: () => _open(booking),
                              ),
                            ),
                        if (_error != null && _page != null)
                          ErrorBanner(_error!),
                        if (_page != null && _page!.page < _page!.lastPage)
                          Center(
                            child: TextButton(
                              onPressed: _loadingMore
                                  ? null
                                  : () => _load(more: true),
                              child: _loadingMore
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(context.text.loadMore),
                            ),
                          ),
                      ],
                    ),
                  )
                : _Message(
                    icon: Icons.lock_person_outlined,
                    text: context.text.signInForBookings,
                    actionLabel: context.text.login,
                    onAction: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                  ),
          ),
        ],
      ),
      backgroundColor: context.colors.background,
    );
  }
}

class _BookingsTabs extends StatelessWidget {
  const _BookingsTabs({required this.scope, required this.onSelected});
  final String scope;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: context.colors.border)),
    ),
    child: Row(
      children: [
        for (final tab in ['upcoming', 'past'])
          Expanded(
            child: InkWell(
              onTap: () => onSelected(tab),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    tab == 'upcoming'
                        ? context.text.upcoming
                        : context.text.past,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: scope == tab
                          ? context.colors.primary
                          : context.colors.textSecondary,
                      fontWeight: scope == tab
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 52,
                    height: 2,
                    color: scope == tab
                        ? context.colors.primary
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
