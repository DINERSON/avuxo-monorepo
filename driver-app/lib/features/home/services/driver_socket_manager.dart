import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/storage/local_storage.dart';
import '../controllers/home_controller.dart';
import 'socket_service.dart';

class DriverSocketManager {
  DriverSocketManager({
    required this.dio,
    required this.storage,
    required this.controller,
  });

  final Dio dio;
  final LocalStorage storage;
  final HomeController controller;

  Timer? _ridePollingTimer;

  bool _checkingRide = false;

  Future<void> connect({
    required String? currentRideId,
    required void Function(Map<String, dynamic> ride) onRideAvailable,
    required void Function(Map<String, dynamic> ride) onRideUpdate,
    required void Function(List<Map<String, dynamic>> messages)
        onChatUpdated,
  }) async {
    final driverId = await storage.getDriverId();

    SocketService.instance.connect(
      driverId: driverId ?? 'driver-avuxo',
      onRideAvailable: (ride) {
        if (ride is! Map) return;

        final incomingRide =
            Map<String, dynamic>.from(ride);

        onRideAvailable(incomingRide);
      },
      onRideUpdate: (ride) {
        if (ride is! Map) return;

        final updatedRide =
            Map<String, dynamic>.from(ride);

        onRideUpdate(updatedRide);
      },
      onChatUpdated: (data) {
        final messages = _extractMessages(data);

        if (messages == null) return;

        onChatUpdated(messages);
      },
    );

    if (currentRideId != null &&
        currentRideId.trim().isNotEmpty) {
      SocketService.instance.joinRide(
        currentRideId.trim(),
      );
    }
  }

  void startRidePolling({
    required String? Function() getCurrentRideId,
    required void Function(Map<String, dynamic> ride)
        onRideFound,
  }) {
    stopRidePolling();

    _ridePollingTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        checkCurrentRideFallback(
          getCurrentRideId: getCurrentRideId,
          onRideFound: onRideFound,
        );
      },
    );

    checkCurrentRideFallback(
      getCurrentRideId: getCurrentRideId,
      onRideFound: onRideFound,
    );
  }

  void stopRidePolling() {
    _ridePollingTimer?.cancel();
    _ridePollingTimer = null;
  }

  Future<void> checkCurrentRideFallback({
    required String? Function() getCurrentRideId,
    required void Function(Map<String, dynamic> ride)
        onRideFound,
  }) async {
    if (_checkingRide) return;

    if (!controller.isOnline) return;

    if (controller.hasIncomingRide ||
        controller.rideAccepted ||
        controller.arriving ||
        controller.inProgress ||
        controller.finished) {
      return;
    }

    _checkingRide = true;

    try {
      final currentRideId = getCurrentRideId();

      final response = await dio
          .get(
            '/ride/current',
            queryParameters: {
              if (currentRideId != null &&
                  currentRideId.trim().isNotEmpty)
                'rideId': currentRideId.trim(),
            },
          )
          .timeout(
            const Duration(seconds: 10),
          );

      final data = response.data;

      if (data is! Map) return;

      final ride = data['ride'];

      if (ride is! Map) return;

      final rideId =
          '${ride['rideId'] ?? ride['id'] ?? ''}'
              .trim();

      if (rideId.isEmpty) return;

      final status =
          '${ride['status'] ?? ''}'.trim();

      if (status != 'pending' &&
          status != 'searching') {
        return;
      }

      onRideFound(
        Map<String, dynamic>.from(ride),
      );
    } catch (_) {
      //
    } finally {
      _checkingRide = false;
    }
  }

  void requestChat(String? rideId) {
    if (rideId == null ||
        rideId.trim().isEmpty) {
      return;
    }

    SocketService.instance.requestChat(
      rideId.trim(),
    );
  }

  void disconnect() {
    stopRidePolling();

    SocketService.instance.disconnect();
  }

  List<Map<String, dynamic>>? _extractMessages(
    dynamic data,
  ) {
    dynamic chat;

    if (data is Map) {
      chat = data['chat'];
      chat ??= data['messages'];
    } else {
      chat = data;
    }

    if (chat is! List) return null;

    return chat
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  void dispose() {
    stopRidePolling();
  }
}