import 'package:booking_app/core/services/storage/shared_preferences_service.dart';
import 'package:booking_app/core/services/storage/storage_keys.dart';
import 'package:flutter/material.dart';

abstract interface class ThemeStorageService {
  ThemeMode getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}

class ThemeStorageServiceImpl implements ThemeStorageService {
  const ThemeStorageServiceImpl(this._storage);

  final SharedPreferencesService _storage;

  @override
  ThemeMode getThemeMode() {
    final saved = _storage.getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final saved = await _storage.setString(StorageKeys.themeMode, mode.name);
    if (!saved) throw StateError('Unable to save theme mode.');
  }
}
