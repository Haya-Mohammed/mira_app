import 'package:characters/characters.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatting helpers.

/// final locale = Localizations.localeOf(context).toString();
/// Formatter.formatDate(date, locale);

class Formatter {
  Formatter._();

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';

    String first(String word) => word.characters.first.toUpperCase();

    if (parts.length == 1) return first(parts.first);
    return '${first(parts.first)}${first(parts.last)}';
  }

  static String formatDate(DateTime? date, String locale) {
    if (date == null) return '—';
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  static String formatDateTime(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
  }

  static String formatTime(DateTime date, String locale) {
    return DateFormat.jm(locale).format(date.toLocal());
  }

  static String currency(
    double value,
    String locale, {
    String currencyCode = 'USD',
  }) {
    return NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    ).format(value);
  }
}
