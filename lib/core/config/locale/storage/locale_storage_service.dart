import 'package:booking_app/core/services/storage/shared_preferences_service.dart';
import 'package:booking_app/core/services/storage/storage_keys.dart';

abstract interface class LocaleStorageService {
  String? getLocaleCode();
  Future<void> saveLocaleCode(String localeCode);
}

class LocaleStorageServiceImpl implements LocaleStorageService {
  const LocaleStorageServiceImpl(this._storage);

  final SharedPreferencesService _storage;

  @override
  String? getLocaleCode() => _storage.getString(StorageKeys.locale);

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    final saved = await _storage.setString(StorageKeys.locale, localeCode);
    if (!saved) throw StateError('Unable to save locale.');
  }
}
