import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:booking_app/core/widgets/app_text_field.dart';
import 'package:booking_app/features/auth/domain/entities/auth_user.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/home/data/models/place_model.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:booking_app/features/home/presentation/cubit/home_state.dart';
import 'package:booking_app/features/home/presentation/screens/place_info_screen.dart';
import 'package:booking_app/features/notifications/presentation/notifications_screen.dart';
import 'package:booking_app/features/services/presentation/screens/busy_hours_screen.dart';
import 'package:booking_app/features/services/presentation/screens/reviews_screen.dart';
import 'package:booking_app/features/services/presentation/screens/staff_screens.dart';
import 'package:booking_app/features/settings/presentation/widgets/profile_preferences_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_failure_message.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => sl<HomeCubit>()..fetchHome(), child: const _ProfileContent());
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _editing = false;
  String _savedName = '';
  String _savedPhone = '';

  bool get _isDirty => _name.text.trim() != _savedName || _phone.text.trim() != _savedPhone;

  @override
  void initState() {
    super.initState();
    _syncFrom(context.read<UserCubit>().state);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _syncFrom(UserState state) {
    final user = state.user;
    if (user == null) return;
    _savedName = user.name.trim();
    _savedPhone = user.phone.trim();
    _name.text = user.name;
    _phone.text = user.phone;
  }

  void _startEditing() {
    _syncFrom(context.read<UserCubit>().state);
    context.read<UserCubit>().clearError();
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    _syncFrom(context.read<UserCubit>().state);
    context.read<UserCubit>().clearError();
    setState(() => _editing = false);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final cubit = context.read<UserCubit>();
    cubit.updateProfile(_name.text.trim(), cubit.state.user!.email, _phone.text.trim());
  }

  void _onStateChanged(BuildContext context, UserState state) {
    if (state.status == AuthStatus.guest) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    } else if (state.updated) {
      _syncFrom(state);
      setState(() => _editing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.text.profileUpdated)));
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.text.signOut),
        content: Text(context.text.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.text.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.text.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.read<UserCubit>().signOut();
  }

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) => BlocConsumer<UserCubit, UserState>(
    listenWhen: (previous, current) =>
        previous.status != current.status || (!previous.updated && current.updated),
    listener: _onStateChanged,
    builder: (context, state) {
      final user = state.user;
      if (user == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return PopScope(
        canPop: !_editing,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !state.busy) _cancelEditing();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_editing ? context.text.editProfile : context.text.profile),
            leading: _editing
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: state.busy ? null : _cancelEditing,
                  )
                : null,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: _editing
                      ? [
                          Form(
                            key: _form,
                            child: Column(
                              children: [
                                AppTextField(
                                  label: context.text.name,
                                  controller: _name,
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  errorText: state.failure?.fieldError('name'),
                                  onChanged: (_) => context.read<UserCubit>().clearError(),
                                  validator: (value) => value == null || value.trim().isEmpty
                                      ? context.text.requiredField
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: context.text.phone,
                                  controller: _phone,
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  errorText: state.failure?.fieldError('phone'),
                                  onChanged: (_) => context.read<UserCubit>().clearError(),
                                  validator: (value) => value == null || value.trim().isEmpty
                                      ? context.text.requiredField
                                      : null,
                                ),
                                if (state.failure != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    state.failure!.authMessage(context),
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                ListenableBuilder(
                                  listenable: Listenable.merge([_name, _phone]),
                                  builder: (context, _) => AppButton(
                                    label: context.text.saveChanges,
                                    loading: state.busy,
                                    onPressed: state.busy || !_isDirty ? null : _save,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      : [
                          _AccountCard(user: user, onEdit: _startEditing),
                          const SizedBox(height: 16),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _ActionTile(
                                  icon: Icons.notifications_none_rounded,
                                  label: context.text.notifications,
                                  onTap: () => _open(const NotificationsScreen()),
                                ),
                                const Divider(height: 1),
                                _ActionTile(
                                  icon: Icons.people_outline_rounded,
                                  label: context.text.ourTeam,
                                  onTap: () => _open(const StaffScreen()),
                                ),
                                const Divider(height: 1),
                                _ActionTile(
                                  icon: Icons.star_outline_rounded,
                                  label: context.text.reviews,
                                  onTap: () => _open(const ReviewsScreen()),
                                ),
                                const Divider(height: 1),
                                _ActionTile(
                                  icon: Icons.auto_graph_rounded,
                                  label: context.text.bestTimes,
                                  onTap: () => _open(const BusyHoursScreen()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const ProfilePreferencesCard(),
                          const SizedBox(height: 16),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, homeState) {
                              if (homeState is! HomeLoaded || homeState.data.place == null) {
                                return const SizedBox.shrink();
                              }
                              return _PlaceCard(
                                place: homeState.data.place!,
                                onTap: () => _open(PlaceInfoScreen(place: homeState.data.place!)),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: state.busy ? null : _confirmSignOut,
                            icon: const Icon(Icons.logout_rounded),
                            label: Text(context.text.signOut),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.onEdit});
  final AuthUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final score = user.reliability?.score.clamp(0, 100);
    final hasPhone = user.phone.trim().isNotEmpty;

    // Layout follows the active text direction: avatar on the start side,
    // edit button on the end side. (The old card forced LTR on every row.)
    return AppCard(
      color: colors.primaryMuted,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.35), width: 2),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.primary,
                  child: Text(
                    user.initials,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      _ContactLine(icon: Icons.mail_outline_rounded, value: user.email),
                      if (hasPhone) ...[
                        const SizedBox(height: 6),
                        _ContactLine(icon: Icons.phone_outlined, value: user.phone),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onEdit,
                tooltip: context.text.editProfile,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          if (score != null) ...[const SizedBox(height: 20), _ReliabilityPanel(score: score)],
        ],
      ),
    );
  }
}

/// Icon + value line. Emails and phone numbers are always laid out
/// left-to-right so '+' signs and '@' don't get reordered in RTL locales.
class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: context.colors.primary),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
          style: context.textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

class _ReliabilityPanel extends StatelessWidget {
  const _ReliabilityPanel({required this.score});
  final num score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final tone = score >= 80
        ? Colors.green.shade700
        : score >= 50
        ? Colors.orange.shade800
        : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 20, color: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.text.reliabilityScore,
                  style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${score.round()}',
                        style: TextStyle(color: tone, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: ' / 100',
                        style: TextStyle(color: scheme.outline),
                      ),
                    ],
                  ),
                  style: context.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: colors.border,
                color: tone,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(context.text.reliabilityHint, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onTap});
  final PlaceModel place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          place.name,
          textAlign: TextAlign.end,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (place.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            place.description!,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall,
          ),
        ],
        if (place.contact?.address?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _PlaceDetail(Icons.location_on_outlined, place.contact!.address!),
        ],
        if (place.contact?.phone?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          _PlaceDetail(Icons.phone_outlined, place.contact!.phone!),
        ],
      ],
    ),
  );
}

class _PlaceDetail extends StatelessWidget {
  const _PlaceDetail(this.icon, this.value);
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: Text(value, textAlign: TextAlign.end, style: context.textTheme.bodySmall),
      ),
      const SizedBox(width: 8),
      Icon(icon, size: 18, color: context.colors.primary),
    ],
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: context.colors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
