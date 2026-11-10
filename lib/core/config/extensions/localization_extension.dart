import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get text => AppLocalizations.of(this);
}
