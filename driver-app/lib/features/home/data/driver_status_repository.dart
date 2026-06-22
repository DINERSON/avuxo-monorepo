import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class DriverStatusRepository {
  DriverStatusRepository(this._dio);

  final Dio _dio;

  Future<bool> setOnlineStatus({
    required String driverId,
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio
          .patch(
            '/drivers/$driverId/online-status',
            data: {
              'is_online': isOnline,
              'current_location': {
                'lat': lat,
                'lng': lng,
              },
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ONLINE STATUS ERROR: $e');
      }

      return false;
    }
  }

  Future<bool> sendLocationUpdate({
    required double lat,
    required double lng,
    String? rideId,
  }) async {
    try {
      final payload = {
        'lat': lat,
        'lng': lng,
      };

      if (rideId != null && rideId.trim().isNotEmpty) {
        payload['rideId'] = rideId.trim();
        payload['ride_id'] = rideId.trim();
      }

      final response = await _dio
          .post(
            '/tracking/driver/location',
            data: payload,
          )
          .timeout(
            const Duration(seconds: 10),
          );

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TRACKING ERROR: $e');
      }

      return false;
    }
  }

  Future<bool> saveDeviceToken(String fcmToken) async {
    try {
      final response = await _dio
          .post(
            '/drivers/me/device-token',
            data: {
              'fcm_token': fcmToken.trim(),
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM TOKEN ERROR: $e');
      }

      return false;
    }
  }
}

final driverStatusRepositoryProvider =
    Provider<DriverStatusRepository>((ref) {
  return DriverStatusRepository(
    ref.watch(apiClientProvider),
  );
});