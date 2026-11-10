import 'package:flutter/painting.dart';

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 8; // checkbox, chip
  static const double md = 12; // input field
  static const double lg = 16; // card, bottom sheet
  static const double xl = 24;
  static const double pill = 999; // badge, round button

  // Ready-made BorderRadius values (avoid rebuilding them in widgets).
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Bottom sheets: rounded top corners only.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
