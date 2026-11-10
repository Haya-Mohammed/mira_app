import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/features/settings/presentation/widgets/profile_preferences_card.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.text.settings)),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [ProfilePreferencesCard()],
          ),
        ),
      ),
    ),
  );
}
