import 'dart:ui';

import 'package:booking_app/app.dart';
import 'package:booking_app/core/di/injection_container.dart' as di;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Errors thrown inside the Flutter framework (build, layout, gestures).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO: report to your crash service (e.g. Crashlytics / Sentry).
  };

  // Uncaught async errors that never reach the framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    // TODO: report to your crash service.
    return true;
  };

  try {
    await dotenv.load(fileName: '.env');
    await di.initDependencies();
  } catch (error, stackTrace) {
    debugPrint('Startup failed: $error\n$stackTrace');
    runApp(StartupErrorApp(error: error));
    return;
  }

  runApp(const MyApp());
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذّر تشغيل التطبيق. حاول إعادة فتحه.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The app could not start. Please reopen it.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
