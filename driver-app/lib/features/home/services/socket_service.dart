import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService instance = SocketService._internal();

  SocketService._internal();

  static const String baseUrl =
      'https://avuxo-backend-production.up.railway.app';

  io.Socket? socket;

  bool connected = false;
  bool _connecting = false;

  String _driverId = 'driver-avuxo';

  String? currentRideId;
  String? _lastJoinedRideId;

  final Map<String, DateTime> _eventDebounce = {};

  void connect({
    required void Function(dynamic ride) onRideUpdate,
    required void Function(dynamic ride) onRideAvailable,
    void Function(dynamic data)? onChatUpdated,
    String driverId = 'driver-avuxo',
  }) {
    if (_connecting) return;

    _connecting = true;

    _driverId = driverId.trim().isEmpty ? 'driver-avuxo' : driverId.trim();

    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();

    connected = false;

    socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(800)
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      connected = true;
      _connecting = false;
      _joinDriverRooms();

      final id = currentRideId;
      if (id != null && id.trim().isNotEmpty) {
        _lastJoinedRideId = null;
        joinRide(id);
      }
    });

    socket!.onReconnect((_) {
      connected = true;
      _joinDriverRooms();

      final id = currentRideId;
      if (id != null && id.trim().isNotEmpty) {
        _lastJoinedRideId = null;
        joinRide(id);
      }
    });

    socket!.onConnectError((_) {
      connected = false;
      _connecting = false;
    });

    socket!.onError((_) {
      connected = false;
      _connecting = false;
    });

    socket!.onDisconnect((_) {
      connected = false;
      _connecting = false;
    });

    socket!.on('server:ready', (_) {});

    socket!.on('ride:available', (data) {
      _handleRideAvailable(data, onRideAvailable);
    });

    socket!.on('ride:requested', (data) {
      _handleRideAvailable(data, onRideAvailable);
    });

    socket!.on('ride:update', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:updated', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:current', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:accepted', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:arrived', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:started', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:finished', (data) {
      _handleRideUpdate(data, onRideUpdate);
      clearCurrentRide();
    });

    socket!.on('ride:cancelled', (data) {
      _handleRideUpdate(data, onRideUpdate);
      clearCurrentRide();
    });

    socket!.on('driver:location', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('ride:tracking', (data) {
      _handleRideUpdate(data, onRideUpdate);
    });

    socket!.on('chat:updated', (data) {
      onChatUpdated?.call(data);
    });

    socket!.on('chat:update', (data) {
      onChatUpdated?.call(data);
    });

    socket!.on('chat:message', (data) {
      onChatUpdated?.call(data);
    });

    socket!.connect();
  }

  void _handleRideAvailable(
    dynamic data,
    void Function(dynamic ride) onRideAvailable,
  ) {
    final ride = _extractRide(data);

    if (ride == null) return;

    final rideId = _extractRideId(ride);

    if (rideId == null) return;

    if (currentRideId != null &&
        currentRideId!.isNotEmpty &&
        currentRideId != rideId) {
      return;
    }

    if (!_shouldProcessEvent('available_$rideId')) {
      return;
    }

    _saveRideIdFromRide(ride);
    onRideAvailable(ride);
  }

  void _handleRideUpdate(
    dynamic data,
    void Function(dynamic ride) onRideUpdate,
  ) {
    final ride = _extractRide(data);

    if (ride == null) return;

    final rideId = _extractRideId(ride);

    if (rideId == null) {
      onRideUpdate(ride);
      return;
    }

    if (currentRideId != null &&
        currentRideId!.isNotEmpty &&
        currentRideId != rideId) {
      return;
    }

    final status = _extractRideStatus(ride);

    if (!_shouldProcessEvent('update_${rideId}_$status')) {
      return;
    }

    _saveRideIdFromRide(ride);
    onRideUpdate(ride);
  }

  bool _shouldProcessEvent(String key) {
    final now = DateTime.now();
    final last = _eventDebounce[key];

    if (last != null &&
        now.difference(last) < const Duration(milliseconds: 800)) {
      return false;
    }

    _eventDebounce[key] = now;

    if (_eventDebounce.length > 80) {
      _eventDebounce.clear();
    }

    return true;
  }

  void _joinDriverRooms() {
    socket?.emit('join:driver', _driverId);
    socket?.emit('driver:join', _driverId);

    socket?.emit('driver:online', {
      'driverId': _driverId,
    });

    requestCurrentRide();
  }

  void joinRide(String rideId) {
    final cleanRideId = rideId.trim();

    if (cleanRideId.isEmpty) return;

    currentRideId = cleanRideId;

    if (_lastJoinedRideId == cleanRideId) {
      return;
    }

    _lastJoinedRideId = cleanRideId;

    socket?.emit('join:ride', {
      'rideId': cleanRideId,
      'driverId': _driverId,
    });

    socket?.emit('ride:join', {
      'rideId': cleanRideId,
      'driverId': _driverId,
    });

    requestCurrentRide(cleanRideId);
    requestChat(cleanRideId);
  }

  dynamic _extractRide(dynamic data) {
    if (data == null) return null;

    if (data is Map && data['ride'] != null) {
      return data['ride'];
    }

    if (data is Map && data['data'] != null) {
      return data['data'];
    }

    return data;
  }

  String? _extractRideId(dynamic ride) {
    if (ride == null) return null;

    if (ride is Map) {
      final id = ride['rideId'] ?? ride['id'] ?? ride['_id'] ?? ride['ride_id'];

      if (id == null) return null;

      final clean = id.toString().trim();

      if (clean.isEmpty || clean == 'null') return null;

      return clean;
    }

    return null;
  }

  String _extractRideStatus(dynamic ride) {
    if (ride is! Map) return '';

    return '${ride['status'] ?? ride['rideStatus'] ?? ''}'.trim();
  }

  void _saveRideIdFromRide(dynamic ride) {
    final rideId = _extractRideId(ride);

    if (rideId == null) return;

    currentRideId = rideId;
    joinRide(rideId);
  }

  void requestCurrentRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    socket?.emit('ride:get-current', {
      if (id != null && id.trim().isNotEmpty) 'rideId': id.trim(),
      'driverId': _driverId,
    });
  }

  void requestChat([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) {
      return;
    }

    socket?.emit('chat:get', {
      'rideId': id.trim(),
      'driverId': _driverId,
    });
  }

  void acceptRide({
    String? rideId,
    Map<String, dynamic>? driver,
  }) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    currentRideId = id.trim();
    joinRide(currentRideId!);

    socket?.emit('ride:accept', {
      'rideId': currentRideId,
      'driverId': _driverId,
      'driver': driver ??
          {
            'id': _driverId,
            'driverId': _driverId,
            'name': 'Motorista AVUXO',
          },
    });
  }

  void declineRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit('ride:decline', {
      'rideId': id.trim(),
      'driverId': _driverId,
    });

    clearCurrentRide();
  }

  void arrivedRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit('ride:arrived', {
      'rideId': id.trim(),
      'driverId': _driverId,
    });
  }

  void startRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit('ride:start', {
      'rideId': id.trim(),
      'driverId': _driverId,
    });
  }

  void finishRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit('ride:finish', {
      'rideId': id.trim(),
      'driverId': _driverId,
    });

    clearCurrentRide();
  }

  void cancelRide([String? rideId]) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit('ride:cancel', {
      'rideId': id.trim(),
      'driverId': _driverId,
      'cancelledBy': 'driver',
    });

    clearCurrentRide();
  }

  void sendDriverLocation({
    required double lat,
    required double lng,
    double bearing = 0,
    String? rideId,
  }) {
    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;
    if (lat == 0 || lng == 0) return;
    if (lat.isNaN || lng.isNaN) return;

    socket?.emit('driver:location', {
      'rideId': id.trim(),
      'driverId': _driverId,
      'lat': lat,
      'lng': lng,
      'latitude': lat,
      'longitude': lng,
      'bearing': bearing.isNaN ? 0 : bearing,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  void sendDriverChatMessage(
    String text, {
    String? rideId,
  }) {
    final clean = text.trim();

    if (clean.isEmpty) return;

    final id = rideId ?? currentRideId;

    if (id == null || id.trim().isEmpty) return;

    socket?.emit(
      'chat:send',
      {
        'rideId': id.trim(),
        'driverId': _driverId,
        'sender': 'driver',
        'from': 'driver',
        'role': 'driver',
        'message': clean,
        'text': clean,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  void clearCurrentRide() {
    currentRideId = null;
    _lastJoinedRideId = null;
  }

  void disconnect() {
    if (socket == null) return;

    socket!.emit('driver:offline', {
      'driverId': _driverId,
    });

    socket!.clearListeners();
    socket!.disconnect();
    socket!.dispose();

    socket = null;
    connected = false;
    _connecting = false;

    clearCurrentRide();
  }

  void dispose() {
    disconnect();
  }
}