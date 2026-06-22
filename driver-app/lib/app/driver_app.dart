import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_gate.dart';

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AVUXO Motorista',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      themeAnimationCurve: Curves.easeOutCubic,
      themeAnimationDuration: const Duration(milliseconds: 300),
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFF05070A),
        splashFactory: InkRipple.splashFactory,
        primaryColor: avuxoGreen,
        dividerColor: Colors.white10,
        colorScheme: const ColorScheme.dark(
          primary: avuxoGreen,
          secondary: avuxoGreen,
          surface: Color(0xFF05070A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF05070A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF05070A),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF05070A),
          modalBackgroundColor: Color(0xFF05070A),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF10151E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B1117),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: avuxoGreen,
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: avuxoGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            disabledBackgroundColor: Colors.white12,
            disabledForegroundColor: Colors.white38,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0B1117),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: avuxoGreen,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}