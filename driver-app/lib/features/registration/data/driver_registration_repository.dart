import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class DriverRegistrationRepository {
  DriverRegistrationRepository(this._dio);

  final Dio _dio;

  Future<String> register({
    required String name,
    required String phone,
    required String email,
    required String idDocUrl,
    required String licenseUrl,
    required String carInfo,
    required String carPlate,
  }) async {
    final safeName = name.trim();
    final safePhone = phone.trim();
    final safeEmail = email.trim();
    final safeIdDocUrl = idDocUrl.trim();
    final safeLicenseUrl = licenseUrl.trim();
    final safeCarInfo = carInfo.trim();
    final safeCarPlate = carPlate.trim().toUpperCase();

    if (safeName.isEmpty) {
      throw Exception('Nome obrigatório.');
    }

    if (safePhone.isEmpty) {
      throw Exception('Telefone obrigatório.');
    }

    if (safeEmail.isEmpty) {
      throw Exception('E-mail obrigatório.');
    }

    if (!safeEmail.contains('@')) {
      throw Exception('E-mail inválido.');
    }

    if (safeCarPlate.isEmpty) {
      throw Exception('Placa obrigatória.');
    }

    try {
      final res = await _dio.post(
        '/drivers/register',
        data: {
          'name': safeName,
          'phone': safePhone,
          'email': safeEmail,
          'documents': {
            'id_doc': safeIdDocUrl,
            'license': safeLicenseUrl,
            'car_info': safeCarInfo,
            'car_plate': safeCarPlate,
          },
        },
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      final data = res.data;

      if (data is! Map) {
        throw Exception(
          'Resposta inválida do servidor.',
        );
      }

      final payload = data['data'];

      if (payload is! Map) {
        return 'pending';
      }

      final status =
          '${payload['status'] ?? 'pending'}'
              .trim();

      if (status.isEmpty) {
        return 'pending';
      }

      return status;
    } on DioException catch (e) {
      final message =
          e.response?.data is Map
              ? '${e.response?.data['message'] ?? ''}'
              : '';

      if (message.trim().isNotEmpty) {
        throw Exception(message);
      }

      throw Exception(
        'Falha ao enviar cadastro.',
      );
    } catch (_) {
      rethrow;
    }
  }
}

final driverRegistrationRepositoryProvider =
    Provider<DriverRegistrationRepository>(
  (ref) {
    return DriverRegistrationRepository(
      ref.watch(apiClientProvider),
    );
  },
);