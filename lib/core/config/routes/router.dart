import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/features/auth/presentation/screens/login_screen.dart';
import 'package:booking_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:booking_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:booking_app/features/booking/presentation/bookings_screen.dart';
import 'package:booking_app/features/main/presentation/screens/main_screen.dart';
import 'package:booking_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:booking_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.splash => _route(settings, const SplashScreen()),
      AppRoutes.home => _route(settings, const MainScreen()),
      // No BlocProvider needed: MyApp already provides LocaleCubit and ThemeCubit.
      AppRoutes.settings => _route(settings, const SettingsScreen()),
      AppRoutes.login => _route(settings, const LoginScreen()),
      AppRoutes.signup => _route(settings, const SignupScreen()),
      AppRoutes.profile => _route(settings, const ProfileScreen()),
      AppRoutes.bookings => _route(settings, const BookingsScreen()),
      _ => _route(settings, const _NotFoundPage()),
    };
  }

  static MaterialPageRoute<T> _route<T>(RouteSettings settings, Widget page) =>
      MaterialPageRoute<T>(builder: (_) => page, settings: settings);
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(context.text.pageNotFound)));
}
