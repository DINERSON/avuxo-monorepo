import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/services/auth_gate.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PassengerApp extends ConsumerWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appBootstrapProvider);

    return MaterialApp(
      title: 'Corrida Passageiro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      routes: AppRouter.routes,
    );
  }
}
