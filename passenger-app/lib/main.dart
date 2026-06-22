import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/screens/splash_screen.dart';

import 'features/home/presentation/passenger_activity_screen.dart';
import 'features/home/presentation/passenger_wallet_screen.dart';
import 'features/home/presentation/passenger_promotions_screen.dart';
import 'features/home/presentation/passenger_help_screen.dart';
import 'features/home/presentation/passenger_settings_screen.dart';
import 'features/home/presentation/passenger_account_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF050505),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    const ProviderScope(
      child: AvuxoApp(),
    ),
  );
}

class AvuxoApp extends StatelessWidget {
  const AvuxoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVUXO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/passenger-activity': (_) => const PassengerActivityScreen(),
        '/passenger-wallet': (_) => const PassengerWalletScreen(),
        '/passenger-promotions': (_) => const PassengerPromotionsScreen(),
        '/passenger-help': (_) => const PassengerHelpScreen(),
        '/passenger-settings': (_) => const PassengerSettingsScreen(),
        '/passenger-account': (_) => const PassengerAccountScreen(),
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Color(0xFF050505),
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                color: const Color(0xFF050505),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppColors {
  static const background = Color(0xFF050505);
  static const neonGreen = Color(0xFF00FF8F);
  static const card = Color(0xFF0B0F14);
  static const border = Color(0xFF1A1F27);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF7E8A97);
}

class AppEffects {
  static List<BoxShadow> neonGlow({
    double opacity = 0.35,
  }) {
    return [
      BoxShadow(
        color: AppColors.neonGreen.withOpacity(opacity),
        blurRadius: 22,
        spreadRadius: 1,
      ),
    ];
  }
}

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 700;
  }

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

extension SpaceExtension on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}