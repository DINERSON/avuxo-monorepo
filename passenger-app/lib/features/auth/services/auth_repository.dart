import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';
import 'auth_service.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
  }) : _api = apiClient.instance;

  final Dio _api;

  Future<void> registerPassenger({
    required String name,
    required String phone,
    String? email,
  }) async {
    await _api.post(
      '/auth/register',
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email?.trim(),
        'role': 'passenger',
      },
    );
  }

  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
  }) async {
    final normalizedPhone = AuthService.normalizeBrazilPhone(phone);

    await AuthService.sendPhoneOtp(
      phone: normalizedPhone,
      onCodeSent: (verificationId) {
        onCodeSent(verificationId, null);
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  Future<(String token, UserProfile user)> verifyOtp({
    required String verificationId,
    required String otp,
    required String phone,
  }) async {
    final normalizedPhone = AuthService.normalizeBrazilPhone(phone);

    await AuthService.verifyOtp(
      verificationId: verificationId,
      smsCode: otp,
      phone: normalizedPhone,
    );

    final firebaseUser = AuthService.currentUser;

    if (firebaseUser == null) {
      throw Exception('Usuário não autenticado.');
    }

    final token = await firebaseUser.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token Firebase não recebido.');
    }

    final user = UserProfile(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      phone: firebaseUser.phoneNumber ?? normalizedPhone,
      email: firebaseUser.email,
      role: 'passenger',
    );

    return (token, user);
  }

  Future<void> signOut() async {
    await AuthService.logout();
  }
}
