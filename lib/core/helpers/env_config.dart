import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class EnvConfig {
  static String get apiBaseUrl => _required('API_BASE_URL');

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required env value "$key". Check your .env file.',
      );
    }
    return value;
  }
}
