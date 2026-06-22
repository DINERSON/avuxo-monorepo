import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/storage/local_storage.dart';

class RideService {
  RideService({
    required this.dio,
    required this.storage,
  });

  final Dio dio;
  final LocalStorage storage;

  String _cleanRideId(String? rideId) {
    return '${rideId ?? ''}'.trim();
  }

  Future<String> _driverId() async {
    final driverId = await storage.getDriverId();
    final clean = '${driverId ?? ''}'.trim();

    return clean.isNotEmpty ? clean : 'driver-avuxo';
  }

  Future<void> _validateResponse(Response<dynamic> response) async {
    final data = response.data;

    if (response.statusCode == null) {
      throw Exception('Sem resposta do servidor.');
    }

    if (response.statusCode! >= 400) {
      if (data is Map && data['message'] != null) {
        throw Exception(data['message']);
      }

      throw Exception('Erro ${response.statusCode} no servidor.');
    }

    if (data is Map &&
        data.containsKey('success') &&
        data['success'] == false) {
      throw Exception(data['message'] ?? 'Operação não autorizada.');
    }
  }

  Map<String, dynamic>? _extractRide(dynamic data) {
    if (data is! Map) return null;

    final ride = data['ride'] ?? data['data'] ?? data['currentRide'];

    if (ride is Map) {
      return Map<String, dynamic>.from(ride);
    }

    return null;
  }

  Future<Map<String, dynamic>?> getCurrentRide(String rideId) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) return null;

    final response = await dio
        .get('/ride/$cleanRideId')
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> getFallbackCurrentRide({
    String? rideId,
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    final response = await dio
        .get(
          '/ride/current',
          queryParameters: {
            if (cleanRideId.isNotEmpty) 'rideId': cleanRideId,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> acceptRide({
    required String rideId,
    required Map<String, dynamic> driverPayload,
    required LatLng currentPosition,
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final driverId = await _driverId();

    final response = await dio
        .post(
          '/ride/accept',
          data: {
            'rideId': cleanRideId,
            'driverId': driverId,
            ...driverPayload,
            'lat': currentPosition.latitude,
            'lng': currentPosition.longitude,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    await storage.saveCurrentRideId(cleanRideId);

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> declineRide({
    required String rideId,
    String reason = 'Recusada pelo motorista',
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final response = await dio
        .post(
          '/ride/decline',
          data: {
            'rideId': cleanRideId,
            'driverId': await _driverId(),
            'cancelledBy': 'driver',
            'reason': reason,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    await storage.clearCurrentRideId();

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> arrivedPassenger({
    required String rideId,
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final response = await dio
        .post(
          '/ride/arrived',
          data: {
            'rideId': cleanRideId,
            'driverId': await _driverId(),
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> startTrip({
    required String rideId,
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final response = await dio
        .post(
          '/ride/start',
          data: {
            'rideId': cleanRideId,
            'driverId': await _driverId(),
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> finishTrip({
    required String rideId,
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final response = await dio
        .post(
          '/ride/finish',
          data: {
            'rideId': cleanRideId,
            'driverId': await _driverId(),
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    await storage.clearCurrentRideId();

    return _extractRide(response.data);
  }

  Future<Map<String, dynamic>?> cancelRide({
    required String rideId,
    String reason = 'Cancelada pelo motorista',
  }) async {
    final cleanRideId = _cleanRideId(rideId);

    if (cleanRideId.isEmpty) {
      throw Exception('rideId inválido.');
    }

    final response = await dio
        .post(
          '/ride/cancel',
          data: {
            'rideId': cleanRideId,
            'driverId': await _driverId(),
            'cancelledBy': 'driver',
            'reason': reason,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    await storage.clearCurrentRideId();

    return _extractRide(response.data);
  }

  Future<List<Map<String, dynamic>>> history() async {
    final driverId = await _driverId();

    final response = await dio
        .get(
          '/ride/history',
          queryParameters: {
            'driverId': driverId,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    final data = response.data;

    if (data is! Map) return [];

    final rides = data['rides'] ?? data['history'] ?? data['data'];

    if (rides is! List) return [];

    return rides
        .whereType<Map>()
        .map((ride) => Map<String, dynamic>.from(ride))
        .toList();
  }
}