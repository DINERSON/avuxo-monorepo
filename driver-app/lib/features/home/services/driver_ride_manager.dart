import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/storage/local_storage.dart';
import 'socket_service.dart';

class DriverRideManager {
  DriverRideManager({
    required this.dio,
    required this.storage,
  });

  final Dio dio;
  final LocalStorage storage;

  double numValue(dynamic value) {
    return double.tryParse('${value ?? 0}') ?? 0;
  }

  String driverText(
    Map<String, dynamic> profile,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = '${profile[key] ?? ''}'.trim();

      if (value.isNotEmpty && value != 'null') {
        return value;
      }
    }

    return fallback;
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
      throw Exception(
        data['message'] ?? 'Operação não autorizada.',
      );
    }
  }

  String _cleanDriverId(String? driverId) {
    final clean = '${driverId ?? ''}'.trim();
    return clean.isNotEmpty ? clean : 'driver-avuxo';
  }

  Future<void> acceptRide({
    required String rideId,
    required Map<String, dynamic> driverProfile,
    required LatLng currentPosition,
    required void Function() onSuccess,
  }) async {
    final cleanRideId = rideId.trim();
    if (cleanRideId.isEmpty) return;

    final driverId = await storage.getDriverId();
    final name = await storage.getName();
    final phone = await storage.getPhone();

    final driverName = driverText(
      driverProfile,
      ['fullName', 'name', 'driverName'],
      name ?? 'Motorista AVUXO',
    );

    final carBrand = driverText(driverProfile, ['carBrand', 'brand'], '');
    final carModel = driverText(driverProfile, ['carModel', 'model'], '');
    final carColor = driverText(driverProfile, ['carColor', 'color'], '');

    final plate = driverText(
      driverProfile,
      ['carPlate', 'plate', 'licensePlate'],
      '',
    );

    final driverPhoto = driverText(
      driverProfile,
      ['driverPhoto', 'photo', 'profilePhoto'],
      '',
    );

    final vehiclePhoto = driverText(
      driverProfile,
      ['vehiclePhoto', 'carPhoto', 'vehicleImage'],
      '',
    );

    final vehicleName = [
      carBrand,
      carModel,
    ].where((e) => e.trim().isNotEmpty).join(' ').trim();

    final cleanDriverId = _cleanDriverId(driverId);

    final driverPayload = {
      'id': cleanDriverId,
      'driverId': cleanDriverId,
      'name': driverName,
      'fullName': driverName,
      'phone': phone ?? '',
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'vehicle': vehicleName.isEmpty ? 'Veículo AVUXO' : vehicleName,
      'car': vehicleName.isEmpty ? 'Veículo AVUXO' : vehicleName,
      'carBrand': carBrand,
      'carModel': carModel,
      'carColor': carColor,
      'plate': plate,
      'carPlate': plate,
      'rating': numValue(driverProfile['rating'] ?? 5),
      'driverRating': numValue(driverProfile['rating'] ?? 5),
      'photo': driverPhoto,
      'driverPhoto': driverPhoto,
      'vehiclePhoto': vehiclePhoto,
      'carPhoto': vehiclePhoto,
    };

    final response = await dio
        .post(
          '/ride/accept',
          data: {
            'rideId': cleanRideId,
            ...driverPayload,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    await storage.saveCurrentRideId(cleanRideId);

    SocketService.instance.acceptRide(
      rideId: cleanRideId,
      driver: driverPayload,
    );

    HapticFeedback.mediumImpact();
    onSuccess();
  }

  Future<void> declineRide({
    required String rideId,
    required void Function() onSuccess,
  }) async {
    final cleanRideId = rideId.trim();
    if (cleanRideId.isEmpty) return;

    final driverId = _cleanDriverId(await storage.getDriverId());

    final response = await dio
        .post(
          '/ride/decline',
          data: {
            'rideId': cleanRideId,
            'driverId': driverId,
            'cancelledBy': 'driver',
            'reason': 'Recusada pelo motorista',
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    SocketService.instance.declineRide(cleanRideId);
    await storage.clearCurrentRideId();

    HapticFeedback.mediumImpact();
    onSuccess();
  }

  Future<void> arrivedPassenger({
    required String rideId,
    required void Function() onSuccess,
  }) async {
    final cleanRideId = rideId.trim();
    if (cleanRideId.isEmpty) return;

    final driverId = _cleanDriverId(await storage.getDriverId());

    final response = await dio
        .post(
          '/ride/arrived',
          data: {
            'rideId': cleanRideId,
            'driverId': driverId,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    SocketService.instance.arrivedRide(cleanRideId);

    HapticFeedback.mediumImpact();
    onSuccess();
  }

  Future<void> startTrip({
    required String rideId,
    required void Function() onSuccess,
  }) async {
    final cleanRideId = rideId.trim();
    if (cleanRideId.isEmpty) return;

    final driverId = _cleanDriverId(await storage.getDriverId());

    final response = await dio
        .post(
          '/ride/start',
          data: {
            'rideId': cleanRideId,
            'driverId': driverId,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    SocketService.instance.startRide(cleanRideId);

    HapticFeedback.mediumImpact();
    onSuccess();
  }

  Future<void> finishTrip({
    required String rideId,
    required void Function() onSuccess,
  }) async {
    final cleanRideId = rideId.trim();
    if (cleanRideId.isEmpty) return;

    final driverId = _cleanDriverId(await storage.getDriverId());

    final response = await dio
        .post(
          '/ride/finish',
          data: {
            'rideId': cleanRideId,
            'driverId': driverId,
          },
        )
        .timeout(const Duration(seconds: 15));

    await _validateResponse(response);

    SocketService.instance.finishRide(cleanRideId);
    await storage.clearCurrentRideId();

    HapticFeedback.heavyImpact();
    onSuccess();
  }
}