import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/widgets/app_logo.dart';
import 'package:booking_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows salon branding then replaces itself with Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.home: (_) => const Scaffold(body: Text('Home destination')),
        },
      ),
    );
    await tester.pump();

    expect(find.text('Mira'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Your moment to shine'), findsOneWidget);
    expect(find.text('Home destination'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();
    expect(find.text('Home destination'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      false,
    );
  });

  testWidgets('fits a compact screen in dark mode', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SplashScreen(),
        routes: {AppRoutes.home: (_) => const Scaffold(body: Text('Home'))},
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Your moment to shine'), findsOneWidget);
  });
}
