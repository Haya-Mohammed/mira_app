import 'package:booking_app/core/config/theme/service/theme_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_storage.getThemeMode());

  final ThemeStorageService _storage;

  /// Explicit choice (System / Light / Dark). Preferred in a settings screen.
  Future<void> setTheme(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    try {
      await _storage.saveThemeMode(mode);
    } catch (e, st) {
      debugPrint('ThemeCubit: failed to persist theme: $e\n$st');
    }
  }

  /// Quick toggle (e.g. an app-bar icon).
  Future<void> toggle(Brightness current) =>
      setTheme(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
