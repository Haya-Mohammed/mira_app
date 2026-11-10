import 'package:booking_app/core/config/locale/cubit/locale_state.dart';
import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/locale/storage/locale_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static final supportedLocales = AppLocalizations.supportedLocales;
  static const defaultLocale = Locale('ar');

  final LocaleStorageService storageService;

  LocaleCubit(this.storageService)
    : super(LocaleState(_restoreLocale(storageService)));

  static Locale _restoreLocale(LocaleStorageService storage) {
    final savedCode = storage.getLocaleCode();
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == savedCode,
      orElse: () => defaultLocale,
    );
  }

  Future<void> changeLocale(Locale locale) async {
    final target = supportedLocales
        .where((l) => l.languageCode == locale.languageCode)
        .firstOrNull;
    if (target == null || target.languageCode == state.locale.languageCode) {
      return;
    }

    emit(LocaleState(target));
    try {
      await storageService.saveLocaleCode(target.languageCode);
    } catch (e, st) {
      debugPrint('LocaleCubit: failed to persist locale: $e\n$st');
    }
  }

  Future<void> toggleLocale() {
    final current = supportedLocales.indexWhere(
      (l) => l.languageCode == state.locale.languageCode,
    );
    return changeLocale(
      supportedLocales[(current + 1) % supportedLocales.length],
    );
  }
}
