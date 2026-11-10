import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: context.textTheme.titleSmall);
}
