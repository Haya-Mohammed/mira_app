import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive key/value storage. Never store tokens here.
class SharedPreferencesService {
  const SharedPreferencesService(this._storage);

  final SharedPreferences _storage;

  String? getString(String key) => _storage.getString(key);
  Future<bool> setString(String key, String value) =>
      _storage.setString(key, value);

  int? getInt(String key) => _storage.getInt(key);
  Future<bool> setInt(String key, int value) => _storage.setInt(key, value);

  double? getDouble(String key) => _storage.getDouble(key);
  Future<bool> setDouble(String key, double value) =>
      _storage.setDouble(key, value);

  bool? getBool(String key) => _storage.getBool(key);
  Future<bool> setBool(String key, bool value) => _storage.setBool(key, value);

  List<String>? getStringList(String key) => _storage.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) =>
      _storage.setStringList(key, value);

  Future<bool> remove(String key) => _storage.remove(key);
  Future<bool> clearAll() => _storage.clear();

  bool containsKey(String key) => _storage.containsKey(key);
}
