import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class RideRepository {
  RideRepository(this._dio);

  final Dio _dio;

  String _safeId(
    String value,
    String field,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      throw Exception('$field obrigatório.');
    }

    return text;
  }

  Future<void> acceptRide({
    required String rideId,
    required String driverId,
  }) async {
    final safeRideId =
        _safeId(rideId, 'Ride ID');

    final safeDriverId =
        _safeId(driverId, 'Driver ID');

    try {
      final response = await _dio.patch(
        '/rides/$safeRideId/accept',
        data: {
          'driver_id': safeDriverId,
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 20),
          receiveTimeout:
              const Duration(seconds: 20),
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 400) {
        throw Exception(
          'Falha ao aceitar corrida.',
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map &&
          data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception(
        'Erro ao aceitar corrida.',
      );
    }
  }

  Future<void> rejectRide({
    required String rideId,
    required String driverId,
    String reason = 'manual_reject',
  }) async {
    final safeRideId =
        _safeId(rideId, 'Ride ID');

    final safeDriverId =
        _safeId(driverId, 'Driver ID');

    try {
      final response = await _dio.patch(
        '/rides/$safeRideId/reject',
        data: {
          'driver_id': safeDriverId,
          'reason': reason.trim(),
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 20),
          receiveTimeout:
              const Duration(seconds: 20),
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 400) {
        throw Exception(
          'Falha ao recusar corrida.',
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map &&
          data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception(
        'Erro ao recusar corrida.',
      );
    }
  }

  Future<void> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    final safeRideId =
        _safeId(rideId, 'Ride ID');

    final safeStatus = status.trim();

    if (safeStatus.isEmpty) {
      throw Exception(
        'Status obrigatório.',
      );
    }

    try {
      final response = await _dio.patch(
        '/rides/$safeRideId/status',
        data: {
          'status': safeStatus,
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 20),
          receiveTimeout:
              const Duration(seconds: 20),
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 400) {
        throw Exception(
          'Falha ao atualizar status.',
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map &&
          data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception(
        'Erro ao atualizar status.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> history({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/rides/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          receiveTimeout:
              const Duration(seconds: 20),
        ),
      );

      final data = response.data;

      if (data is! Map) {
        return [];
      }

      final root =
          data['data'];

      if (root is! Map) {
        return [];
      }

      final items =
          root['items'];

      if (items is! List) {
        return [];
      }

      return items
          .whereType<Map>()
          .map(
            (e) => Map<String, dynamic>.from(e),
          )
          .toList(growable: false);
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }
}

final rideRepositoryProvider =
    Provider<RideRepository>((ref) {
  return RideRepository(
    ref.watch(apiClientProvider),
  );
});