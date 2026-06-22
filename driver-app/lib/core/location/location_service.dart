import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> hasPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<Position> getCurrent() async {
    final allowed = await hasPermission();

    if (!allowed) {
      throw Exception('Location permission denied');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }

  Future<Position?> getLastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
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
}