# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter application. `lib/main.dart` loads configuration and dependencies; `lib/app.dart` sets up the app, themes, localization, and routes. Shared services, widgets, configuration, and dependency registration live in `lib/core/`. Put feature code under `lib/features/<feature>/`, following the existing `data/`, `domain/`, and `presentation/` layers where applicable. Tests live in `test/`. English and Arabic source strings are in `l10n/*.arb`; generated Dart localization files are in `lib/core/config/locale/generated/`. Platform projects are in `android/`, `ios/`, `web/`, and `windows/`.

## Build, Test, and Development Commands

- `flutter pub get` installs dependencies from `pubspec.yaml`.
- `flutter run` starts the app on a selected device or emulator.
- `flutter build apk` builds an Android release APK; use the corresponding Flutter build target for another platform.
- `flutter gen-l10n` regenerates localization classes after changing ARB files.
- `dart format lib test` formats Dart source and tests.
- `flutter analyze` checks code against `analysis_options.yaml` and `flutter_lints`.
- `flutter test` runs the Flutter test suite.

## Coding Style & Naming Conventions

Use Dart's standard two-space indentation and let `dart format` resolve layout. Name files and directories in `snake_case`, classes in `UpperCamelCase`, and members in `lowerCamelCase`. Keep shared UI in `lib/core/widgets/` and feature-specific UI inside its feature. Follow the existing Cubit pattern for state and register new dependencies in `lib/core/di/injection_container.dart` or the feature's injection file. Add user-facing strings to both ARB files rather than hard-coding them in widgets.

## Testing Guidelines

Use `flutter_test`; name test files `*_test.dart` and place them under `test/`, mirroring the source area when useful. Add focused widget or unit tests for changed behavior. The current `test/widget_test.dart` is a starter counter test and may need updating as the app evolves. No coverage threshold is configured. Run `flutter test` and `flutter analyze` before submitting changes.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout, so no existing commit message convention can be verified. Use short, imperative subjects such as `Add category loading state`. In pull requests, describe the user-visible change, link the relevant issue when one exists, list verification commands, and include screenshots for UI changes.

## Configuration & Security

The app loads `.env` at startup and bundles it as a Flutter asset. Keep credentials and other secrets out of that file; bundled assets can be inspected by app users. Do not commit generated build output or local tool directories such as `build/` and `.dart_tool/`.
