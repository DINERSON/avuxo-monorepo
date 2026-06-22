import 'package:flutter/material.dart';

import '../models/driver_trip_state.dart';

class HomeController extends ChangeNotifier {
  DriverTripState _state = DriverTripState.offline;

  String? _rideId;
  String? _errorMessage;

  DriverTripState get state => _state;

  String? get rideId => _rideId;
  String? get errorMessage => _errorMessage;

  bool get isOffline => _state == DriverTripState.offline;
  bool get isOnline => _state == DriverTripState.online;
  bool get hasIncomingRide => _state == DriverTripState.incomingRide;
  bool get rideAccepted => _state == DriverTripState.accepted;
  bool get arriving => _state == DriverTripState.arriving;
  bool get inProgress => _state == DriverTripState.inProgress;
  bool get finished => _state == DriverTripState.finished;
  bool get cancelled => _state == DriverTripState.cancelled;
  bool get hasError => _state == DriverTripState.error;

  bool get hasActiveRide =>
      hasIncomingRide ||
      rideAccepted ||
      arriving ||
      inProgress;

  void goOnline() {
    if (_state == DriverTripState.blocked) {
      return;
    }

    clearError();
    _setState(DriverTripState.online);
  }

  void goOffline() {
    _rideId = null;
    clearError();
    _setState(DriverTripState.offline);
  }

  void blockDriver([String? reason]) {
    _rideId = null;
    _errorMessage = reason;
    _setState(DriverTripState.blocked);
  }

  void receiveRide(String rideId) {
    final cleanRideId = rideId.trim();

    if (cleanRideId.isEmpty) {
      setError('rideId inválido');
      return;
    }

    if (hasActiveRide) {
      return;
    }

    _rideId = cleanRideId;

    clearError();

    _setState(DriverTripState.incomingRide);
  }

  void acceptRide([String? rideId]) {
    if (_state != DriverTripState.incomingRide &&
        _state != DriverTripState.accepted) {
      return;
    }

    if (rideId != null &&
        rideId.trim().isNotEmpty) {
      _rideId = rideId.trim();
    }

    clearError();

    _setState(DriverTripState.accepted);
  }

  void arrivePassenger() {
    if (_state != DriverTripState.accepted) {
      return;
    }

    clearError();

    _setState(DriverTripState.arriving);
  }

  void startTrip() {
    if (_state != DriverTripState.arriving) {
      return;
    }

    clearError();

    _setState(DriverTripState.inProgress);
  }

  void finishTrip() {
    if (_state != DriverTripState.inProgress) {
      return;
    }

    _rideId = null;

    clearError();

    _setState(DriverTripState.finished);
  }

  void cancelTrip() {
    _rideId = null;

    clearError();

    _setState(DriverTripState.cancelled);
  }

  void declineRide() {
    _rideId = null;

    clearError();

    _setState(DriverTripState.online);
  }

  void resetTrip() {
    _rideId = null;

    clearError();

    _setState(DriverTripState.online);
  }

  void setError([String? message]) {
    _errorMessage = message;
    _setState(DriverTripState.error);
  }

  void clearError() {
    _errorMessage = null;
  }

  void restoreRide({
    required String rideId,
    required DriverTripState state,
  }) {
    final cleanRideId = rideId.trim();

    if (cleanRideId.isEmpty) return;

    _rideId = cleanRideId;

    _setState(state);
  }

  void _setState(DriverTripState newState) {
    if (_state == newState) {
      return;
    }

    _state = newState;

    notifyListeners();
  }
}