import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(apiClient);
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<void> sendOtp({
    required String phone,
    required void Function(String id) onCodeSent,
    required void Function(FirebaseAuthException e) onFailed,
  }) async {
    try {
      final cleanPhone = _normalizePhone(phone);

      if (!_isValidPhone(cleanPhone)) {
        onFailed(
          FirebaseAuthException(
            code: 'invalid-phone',
            message: 'Digite um telefone válido com DDD.',
          ),
        );
        return;
      }

      if (kDebugMode) {
        debugPrint('🟢 AVUXO DRIVER REQUEST');
        debugPrint('POST ${_dio.options.baseUrl}/auth/send-otp');
      }

      final response = await _dio
          .post(
            '/auth/send-otp',
            data: {
              'phone': cleanPhone,
              'role': 'driver',
              'app': 'avuxo-driver',
            },
            options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              validateStatus: (status) => status != null && status < 500,
            ),
          )
          .timeout(const Duration(seconds: 20));

      final data = response.data;

      if (kDebugMode) {
        debugPrint('✅ SEND OTP RESPONSE STATUS: ${response.statusCode}');
        debugPrint('✅ SEND OTP RESPONSE DATA: $data');
      }

      if (response.statusCode != 200 || data is! Map || data['success'] != true) {
        onFailed(
          FirebaseAuthException(
            code: 'otp-failed',
            message: _messageFromData(data, 'Erro ao enviar OTP.'),
          ),
        );
        return;
      }

      final verificationId =
          '${data['verificationId'] ?? data['verification_id'] ?? ''}'.trim();

      if (verificationId.isEmpty) {
        onFailed(
          FirebaseAuthException(
            code: 'empty-verification-id',
            message: 'Servidor não retornou verificação válida.',
          ),
        );
        return;
      }

      onCodeSent(verificationId);
    } on TimeoutException {
      onFailed(
        FirebaseAuthException(
          code: 'timeout',
          message: 'Tempo de conexão esgotado.',
        ),
      );
    } on DioException catch (e) {
      onFailed(
        FirebaseAuthException(
          code: 'network-error',
          message: _dioErrorMessage(e, 'Erro de conexão ao enviar OTP.'),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SEND OTP AVUXO ERROR');
        debugPrint('$e');
      }

      onFailed(
        FirebaseAuthException(
          code: 'otp-failed',
          message: 'Erro de conexão ao enviar OTP.',
        ),
      );
    }
  }

  Future<String> verifyOtp({
    required String verificationId,
    required String code,
    required String phone,
  }) async {
    try {
      final cleanPhone = _normalizePhone(phone);
      final cleanCode = code.trim();

      if (verificationId.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-verification-id',
          message: 'Envie o código primeiro.',
        );
      }

      if (!_isValidPhone(cleanPhone)) {
        throw FirebaseAuthException(
          code: 'invalid-phone',
          message: 'Telefone inválido.',
        );
      }

      if (cleanCode.length < 4) {
        throw FirebaseAuthException(
          code: 'invalid-code',
          message: 'Digite o código recebido.',
        );
      }

      final response = await _dio
          .post(
            '/auth/verify-otp',
            data: {
              'verificationId': verificationId.trim(),
              'verification_id': verificationId.trim(),
              'otp': cleanCode,
              'code': cleanCode,
              'phone': cleanPhone,
              'role': 'driver',
              'app': 'avuxo-driver',
            },
            options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              validateStatus: (status) => status != null && status < 500,
            ),
          )
          .timeout(const Duration(seconds: 20));

      final data = response.data;

      if (kDebugMode) {
        debugPrint('✅ VERIFY OTP RESPONSE STATUS: ${response.statusCode}');
        debugPrint('✅ VERIFY OTP RESPONSE DATA: $data');
      }

      if (response.statusCode != 200 || data is! Map || data['success'] != true) {
        throw FirebaseAuthException(
          code: 'invalid-code',
          message: _messageFromData(data, 'Código inválido.'),
        );
      }

      final token = '${data['token'] ?? ''}'.trim();

      if (token.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-token',
          message: 'Token inválido.',
        );
      }

      return token;
    } on TimeoutException {
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Tempo de conexão esgotado.',
      );
    } on DioException catch (e) {
      throw FirebaseAuthException(
        code: 'network-error',
        message: _dioErrorMessage(e, 'Erro ao validar código.'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ VERIFY OTP AVUXO ERROR');
        debugPrint('$e');
      }

      if (e is FirebaseAuthException) {
        rethrow;
      }

      throw FirebaseAuthException(
        code: 'verify-failed',
        message: 'Erro ao validar código.',
      );
    }
  }

  Future<void> logout() async {
    if (kDebugMode) {
      debugPrint('🚪 LOGOUT AVUXO MOTORISTA');
    }
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return phone.startsWith('+55') && digits.length >= 12 && digits.length <= 13;
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return '';

    if (digits.startsWith('55')) {
      return '+$digits';
    }

    return '+55$digits';
  }

  String _messageFromData(dynamic data, String fallback) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }

  String _dioErrorMessage(DioException error, String fallback) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return fallback;
  }
}