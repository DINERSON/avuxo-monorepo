import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'socket_service.dart';

class DriverTrackingManager {
  StreamSubscription<Position>? _locationSub;

  Position? currentPosition;
  DateTime? _lastTrackingSent;

  Future<Position?> loadCurrentLocation({
    GoogleMapController? mapController,
  }) async {
    try {
      final allowed = await _ensurePermission();

      if (!allowed) return null;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (!_isValidPosition(pos)) return null;

      currentPosition = pos;

      if (mapController != null) {
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: 18,
            ),
          ),
        );
      }

      return pos;
    } catch (_) {
      return null;
    }
  }

  Future<void> startLocationStream({
    required bool Function() shouldSendLocation,
    required String? Function() getRideId,
    required VoidCallback onLocationUpdated,
  }) async {
    await stopLocationStream();

    final allowed = await _ensurePermission();

    if (!allowed) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _locationSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) {
        if (!_isValidPosition(position)) return;

        currentPosition = position;

        if (shouldSendLocation()) {
          final now = DateTime.now();

          if (_lastTrackingSent == null ||
              now.difference(_lastTrackingSent!) >
                  const Duration(seconds: 2)) {
            _lastTrackingSent = now;

            sendLocationToPassenger(
              rideId: getRideId(),
            );
          }
        }

        onLocationUpdated();
      },
      onError: (_) {},
    );
  }

  Future<void> stopLocationStream() async {
    await _locationSub?.cancel();
    _locationSub = null;
    _lastTrackingSent = null;
  }

  void sendLocationToPassenger({
    required String? rideId,
  }) {
    final pos = currentPosition;

    if (pos == null) return;
    if (!_isValidPosition(pos)) return;
    if (rideId == null || rideId.trim().isEmpty) return;

    SocketService.instance.sendDriverLocation(
      rideId: rideId.trim(),
      lat: pos.latitude,
      lng: pos.longitude,
      bearing: pos.heading.isNaN ? 0 : pos.heading,
    );
  }

  LatLng fallbackLatLng(LatLng fallback) {
    final pos = currentPosition;

    if (pos == null || !_isValidPosition(pos)) {
      return fallback;
    }

    return LatLng(
      pos.latitude,
      pos.longitude,
    );
  }

  Polyline? buildSimpleRoute({
    required LatLng from,
    required LatLng to,
  }) {
    if (!_isValidLatLng(from) || !_isValidLatLng(to)) {
      return null;
    }

    return Polyline(
      polylineId: const PolylineId('active_route'),
      points: [from, to],
      color: Colors.black,
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  bool _isValidPosition(Position position) {
    if (position.latitude == 0 || position.longitude == 0) {
      return false;
    }

    if (position.latitude.isNaN || position.longitude.isNaN) {
      return false;
    }

    return true;
  }

  bool _isValidLatLng(LatLng value) {
    if (value.latitude == 0 || value.longitude == 0) {
      return false;
    }

    if (value.latitude.isNaN || value.longitude.isNaN) {
      return false;
    }

    return true;
  }

  Future<void> dispose() async {
    await stopLocationStream();
  }
}