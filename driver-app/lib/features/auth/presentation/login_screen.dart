import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../data/auth_repository.dart';
import 'auth_gate.dart';

final verificationIdProvider = StateProvider<String?>((ref) => null);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();

  late final AnimationController glowController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.92,
      upperBound: 1.04,
    )..repeat(reverse: true);

    final savedPhone = ref.read(registrationPhoneProvider);

    if (savedPhone != null && savedPhone.trim().isNotEmpty) {
      phoneCtrl.text = _formatPhone(savedPhone);
    }
  }

  @override
  void dispose() {
    glowController.dispose();
    phoneCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return '';

    if (digits.startsWith('55')) {
      return '+$digits';
    }

    return '+55$digits';
  }

  String _formatPhone(String value) {
    final normalized = _normalizePhone(value);
    return normalized;
  }

  bool _isValidPhone(String value) {
    final normalized = _normalizePhone(value);
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');

    return normalized.startsWith('+55') &&
        digits.length >= 12 &&
        digits.length <= 13;
  }

  Future<void> sendOtp() async {
    final phone = _normalizePhone(phoneCtrl.text);

    if (!_isValidPhone(phone)) {
      _snack('Digite um telefone válido com DDD.');
      return;
    }

    if (loading) return;

    HapticFeedback.lightImpact();

    setState(() => loading = true);

    try {
      await ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            onCodeSent: (id) {
              ref.read(verificationIdProvider.notifier).state = id;
              ref.read(registrationPhoneProvider.notifier).state = phone;

              _snack('Código enviado com sucesso.');
            },
            onFailed: (e) {
              _snack(e.message ?? 'Erro ao enviar OTP.');
            },
          );
    } catch (e) {
      _snack('Erro ao enviar código: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> verify() async {
    final vId = ref.read(verificationIdProvider);
    final phone = _normalizePhone(phoneCtrl.text);
    final code = codeCtrl.text.trim();

    if (vId == null || vId.trim().isEmpty) {
      _snack('Envie o código primeiro.');
      return;
    }

    if (!_isValidPhone(phone)) {
      _snack('Telefone inválido.');
      return;
    }

    if (code.isEmpty) {
      _snack('Digite o código recebido.');
      return;
    }

    if (loading) return;

    HapticFeedback.mediumImpact();

    setState(() => loading = true);

    try {
      final token = await ref.read(authRepositoryProvider).verifyOtp(
            verificationId: vId,
            code: code,
            phone: phone,
          );

      final storage = LocalStorage();

      final phoneFromStorage = await storage.getPhone();
      final nameFromStorage = await storage.getName();

      await storage.saveSession(
        token: token,
        driverId: phone,
        phone: phoneFromStorage?.trim().isNotEmpty == true
            ? phoneFromStorage!
            : phone,
        name: nameFromStorage?.trim().isNotEmpty == true
            ? nameFromStorage!
            : 'Motorista AVUXO',
      );

      ref.read(authTokenProvider.notifier).state = token;
      ref.read(isLoggedProvider.notifier).state = true;
      ref.read(registrationPhoneProvider.notifier).state = phone;

      if (!mounted) return;

      _snack('Login realizado.');
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? 'Código inválido.');
    } catch (e) {
      _snack('Erro ao entrar: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0B1117),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: avuxoGreen.withOpacity(0.12),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationId = ref.watch(verificationIdProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: ScaleTransition(
              scale: glowController,
              child: _glow(280, 0.22),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: ScaleTransition(
              scale: glowController,
              child: _glow(320, 0.14),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1117).withOpacity(0.82),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: avuxoGreen.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avuxoGreen.withOpacity(0.08),
                            blurRadius: 38,
                            spreadRadius: 2,
                          ),
                          const BoxShadow(
                            color: Colors.black87,
                            blurRadius: 28,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avuxoGreen.withOpacity(0.10),
                              border: Border.all(
                                color: avuxoGreen.withOpacity(0.32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: avuxoGreen.withOpacity(0.28),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_taxi_rounded,
                              color: avuxoGreen,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'AVUXO\nMOTORISTA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Acesse a plataforma premium de motoristas AVUXO.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.58),
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 34),
                          TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\s()-]'),
                              ),
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _inputDecoration(
                              label: 'Telefone (+55)',
                              icon: Icons.phone_rounded,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _primaryButton(
                            text: loading ? 'ENVIANDO...' : 'ENVIAR CÓDIGO',
                            icon: Icons.sms_rounded,
                            onTap: loading ? null : sendOtp,
                          ),
                          if (verificationId != null) ...[
                            const SizedBox(height: 28),
                            TextField(
                              controller: codeCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: _inputDecoration(
                                label: 'Código OTP',
                                icon: Icons.lock_rounded,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _primaryButton(
                              text: loading ? 'ENTRANDO...' : 'ENTRAR',
                              icon: Icons.login_rounded,
                              onTap: loading ? null : verify,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, double opacity) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 90,
        sigmaY: 90,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avuxoGreen.withOpacity(opacity),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.55),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: avuxoGreen,
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.36),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: avuxoGreen,
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: onTap == null ? Colors.white38 : Colors.black,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: onTap == null ? Colors.white38 : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: avuxoGreen,
          disabledBackgroundColor: Colors.white10,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}