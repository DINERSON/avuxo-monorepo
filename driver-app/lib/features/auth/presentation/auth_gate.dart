import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../home/presentation/home_screen.dart';
import '../../registration/presentation/registration_screen.dart';
import 'login_screen.dart';

final hasRegisteredProvider = StateProvider<bool>((ref) => false);
final isApprovedProvider = StateProvider<bool>((ref) => false);
final isLoggedProvider = StateProvider<bool>((ref) => false);
final registrationPhoneProvider = StateProvider<String?>((ref) => null);
final authLoadedProvider = StateProvider<bool>((ref) => false);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://avuxo-backend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ),
  );
});

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSavedSession();
      }
    });
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<Map<String, dynamic>?> _findDriverByPhone(String phone) async {
    final dio = ref.read(dioProvider);
    final currentPhone = _normalizePhone(phone);

    if (currentPhone.isEmpty) return null;

    final response = await dio.get('/drivers/status/$currentPhone');
    final data = response.data;

    if (data is! Map) return null;
    if (data['found'] != true) return null;

    final driverData = data['driver'];

    if (driverData is Map) {
      return {
        ...Map<String, dynamic>.from(driverData),
        'approved': data['approved'] == true,
        'blocked': data['blocked'] == true,
        'blockedReason': data['blockedReason'] ?? '',
        'status': data['status'],
      };
    }

    return {
      'phone': phone,
      'approved': data['approved'] == true,
      'blocked': data['blocked'] == true,
      'blockedReason': data['blockedReason'] ?? '',
      'status': data['status'],
    };
  }

  Future<void> _loadSavedSession() async {
    final storage = LocalStorage();

    final localRegistered = await storage.hasRegistered();
    final phone = await storage.getPhone();

    if (!mounted) return;

    if (!localRegistered || phone == null || phone.trim().isEmpty) {
      ref.read(hasRegisteredProvider.notifier).state = false;
      ref.read(isApprovedProvider.notifier).state = false;
      ref.read(isLoggedProvider.notifier).state = false;
      ref.read(registrationPhoneProvider.notifier).state = phone;
      ref.read(authLoadedProvider.notifier).state = true;
      return;
    }

    try {
      final driver = await _findDriverByPhone(phone);

      if (!mounted) return;

      if (driver == null) {
        ref.read(hasRegisteredProvider.notifier).state = localRegistered;
        ref.read(isApprovedProvider.notifier).state = false;
        ref.read(isLoggedProvider.notifier).state = false;
        ref.read(registrationPhoneProvider.notifier).state = phone;
        ref.read(authLoadedProvider.notifier).state = true;
        return;
      }

      final blocked =
          driver['blocked'] == true || driver['status'] == 'blocked';

      if (blocked) {
        await storage.clearSession();
        await storage.saveBlockedStatus(
          blocked: true,
          reason: '${driver['blockedReason'] ?? ''}',
        );

        if (!mounted) return;

        ref.read(hasRegisteredProvider.notifier).state = true;
        ref.read(isApprovedProvider.notifier).state = true;
        ref.read(isLoggedProvider.notifier).state = false;
        ref.read(registrationPhoneProvider.notifier).state = phone;
        ref.read(authLoadedProvider.notifier).state = true;
        return;
      }

      final approved = driver['approved'] == true;

      if (approved) {
        await storage.resetBlockedStatus();

        final logged = await storage.isLogged();

        if (!mounted) return;

        ref.read(hasRegisteredProvider.notifier).state = true;
        ref.read(isApprovedProvider.notifier).state = true;
        ref.read(isLoggedProvider.notifier).state = logged;
        ref.read(registrationPhoneProvider.notifier).state = phone;
        ref.read(authLoadedProvider.notifier).state = true;
        return;
      }

      ref.read(hasRegisteredProvider.notifier).state = true;
      ref.read(isApprovedProvider.notifier).state = false;
      ref.read(isLoggedProvider.notifier).state = false;
      ref.read(registrationPhoneProvider.notifier).state = phone;
      ref.read(authLoadedProvider.notifier).state = true;
    } catch (_) {
      if (!mounted) return;

      ref.read(hasRegisteredProvider.notifier).state = localRegistered;
      ref.read(registrationPhoneProvider.notifier).state = phone;
      ref.read(authLoadedProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(authLoadedProvider);
    final registered = ref.watch(hasRegisteredProvider);
    final approved = ref.watch(isApprovedProvider);
    final logged = ref.watch(isLoggedProvider);

    if (!loaded) {
      return const AuthLoadingScreen();
    }

    if (!registered) {
      return const RegistrationScreen();
    }

    if (!approved) {
      return const PendingApprovalScreen();
    }

    if (!logged) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF05070A),
      body: Center(
        child: CircularProgressIndicator(
          color: avuxoGreen,
        ),
      ),
    );
  }
}

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  Timer? _timer;
  bool _checking = false;
  String? _lastError;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _checkApproval();

      _timer?.cancel();
      _timer = Timer.periodic(
        const Duration(seconds: 4),
        (_) {
          if (mounted) {
            _checkApproval();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _resetToRegistration() async {
    final storage = LocalStorage();

    await storage.clearSession();
    await storage.clearRegistrationDraft();

    if (!mounted) return;

    ref.read(hasRegisteredProvider.notifier).state = false;
    ref.read(isApprovedProvider.notifier).state = false;
    ref.read(isLoggedProvider.notifier).state = false;
    ref.read(registrationPhoneProvider.notifier).state = null;
  }

  Future<void> _checkApproval() async {
    if (!mounted || _checking) return;

    final phone = ref.read(registrationPhoneProvider);

    if (phone == null || phone.trim().isEmpty) {
      await _resetToRegistration();
      return;
    }

    setState(() {
      _checking = true;
      _lastError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final storage = LocalStorage();

      final currentPhone = _normalizePhone(phone);
      final response = await dio.get('/drivers/status/$currentPhone');
      final data = response.data;

      if (!mounted) return;

      if (data is! Map) {
        setState(() {
          _lastError = 'Resposta inválida do servidor.';
        });
        return;
      }

      if (data['found'] != true) {
        setState(() {
          _lastError = 'Cadastro ainda não localizado. Tente novamente em instantes.';
        });
        return;
      }

      final blocked = data['blocked'] == true || data['status'] == 'blocked';

      if (blocked) {
        _timer?.cancel();

        await storage.clearSession();
        await storage.saveBlockedStatus(
          blocked: true,
          reason: '${data['blockedReason'] ?? ''}',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0B0F18),
            content: Text(
              'Sua conta foi bloqueada.',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

        ref.read(hasRegisteredProvider.notifier).state = true;
        ref.read(isApprovedProvider.notifier).state = true;
        ref.read(isLoggedProvider.notifier).state = false;
        ref.read(registrationPhoneProvider.notifier).state = phone;
        return;
      }

      final approved = data['approved'] == true;

      if (approved) {
        _timer?.cancel();

        await storage.resetBlockedStatus();

        final driverData = data['driver'];
        String driverName = 'Motorista AVUXO';

        if (driverData is Map && driverData['fullName'] != null) {
          final name = driverData['fullName'].toString().trim();
          if (name.isNotEmpty) {
            driverName = name;
          }
        }

        await storage.saveRegistrationState(
          phone: phone,
          name: driverName,
          registered: true,
          approved: true,
          logged: false,
        );

        if (!mounted) return;

        ref.read(hasRegisteredProvider.notifier).state = true;
        ref.read(isApprovedProvider.notifier).state = true;
        ref.read(isLoggedProvider.notifier).state = false;
        ref.read(registrationPhoneProvider.notifier).state = phone;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0B0F18),
            content: Text(
              'Cadastro aprovado. Faça login para continuar.',
              style: TextStyle(
                color: avuxoGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _lastError = 'Não foi possível consultar aprovação: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(registrationPhoneProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F18),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white12,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3300FF88),
                    blurRadius: 40,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: avuxoGreen,
                    size: 70,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cadastro em análise',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Assim que o administrador aprovar seu cadastro, o app libera o login automaticamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (phone != null && phone.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: avuxoGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _checking ? null : _checkApproval,
                      child: _checking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verificar aprovação'),
                    ),
                  ),
                  if (_checking) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Consultando aprovação...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_lastError != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _lastError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
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