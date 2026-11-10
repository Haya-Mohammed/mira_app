import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/locale/cubit/locale_cubit.dart';
import 'package:booking_app/core/config/locale/cubit/locale_state.dart';
import 'package:booking_app/core/config/locale/generated/app_localizations.dart';
import 'package:booking_app/core/config/routes/router.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/config/theme/cubit/theme_cubit.dart';
import 'package:booking_app/core/config/theme/theme.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<UserCubit>.value(value: sl<UserCubit>()..restore()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                onGenerateTitle: (context) => context.text.appTitle,
                debugShowCheckedModeBanner: false,

                /// Theme
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,

                /// Localization
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,

                /// Routes
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRouter.onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
