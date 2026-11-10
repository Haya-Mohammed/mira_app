import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/locale/cubit/locale_cubit.dart';
import 'package:booking_app/core/config/locale/cubit/locale_state.dart';
import 'package:booking_app/core/config/theme/cubit/theme_cubit.dart';
import 'package:booking_app/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePreferencesCard extends StatelessWidget {
  const ProfilePreferencesCard({super.key});

  static const _languageNames = {'ar': 'العربية', 'en': 'English'};

  String _themeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.text.systemMode,
    ThemeMode.light => context.text.lightMode,
    ThemeMode.dark => context.text.darkMode,
  };

  Future<void> _chooseTheme(BuildContext context) async {
    final cubit = context.read<ThemeCubit>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.text.appearance, style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(switch (mode) {
                  ThemeMode.system => Icons.brightness_auto_outlined,
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.dark => Icons.dark_mode_outlined,
                }),
                title: Text(_themeLabel(context, mode)),
                trailing: cubit.state == mode
                    ? Icon(Icons.check_rounded, color: context.colors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.setTheme(mode);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.text.languageChange,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final locale in LocaleCubit.supportedLocales)
              ListTile(
                title: Text(
                  _languageNames[locale.languageCode] ?? locale.languageCode,
                ),
                trailing: cubit.state.locale.languageCode == locale.languageCode
                    ? Icon(Icons.check_rounded, color: context.colors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.changeLocale(locale);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => _PreferenceTile(
            icon: Icons.palette_outlined,
            title: context.text.appearance,
            value: _themeLabel(context, mode),
            onTap: () => _chooseTheme(context),
          ),
        ),
        const Divider(height: 1),
        BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, state) => _PreferenceTile(
            icon: Icons.language_rounded,
            title: context.text.languageChange,
            value:
                _languageNames[state.locale.languageCode] ??
                state.locale.languageCode,
            onTap: () => _chooseLanguage(context),
          ),
        ),
      ],
    ),
  );
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
