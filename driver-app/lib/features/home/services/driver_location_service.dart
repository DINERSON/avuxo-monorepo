import 'dart:async';

import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  StreamSubscription<Position>? _positionSubscription;

  Future<bool> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final allowed = await checkPermission();

      if (!allowed) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  Future<void> startTracking({
    required void Function(Position position) onLocationUpdate,
    void Function(Object error)? onError,
  }) async {
    await stopTracking();

    final allowed = await checkPermission();

    if (!allowed) {
      onError?.call('Permissão de localização negada.');
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      onLocationUpdate,
      onError: (error) {
        onError?.call(error);
      },
    );
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> dispose() async {
    await stopTracking();
  }
}