import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../controllers/home_controller.dart';
import '../models/driver_trip_state.dart';
import '../services/driver_account_manager.dart';
import '../services/driver_ride_manager.dart';
import '../services/driver_socket_manager.dart';
import '../services/driver_tracking_manager.dart';
import '../services/socket_service.dart';
import '../widgets/driver_chat_button.dart';
import '../widgets/chat/driver_ride_chat_sheet.dart';
import '../widgets/rides/ride_progress_timeline.dart';
import '../widgets/rides/ride_request_card.dart';
import '../widgets/rides/trip_running_card.dart';
import '../widgets/navigation/driver_side_menu.dart';
import '../../../core/storage/local_storage.dart';
import '../../auth/presentation/auth_gate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color avuxoGreen = Color(0xFF24F877);

  final AudioPlayer _rideAudio = AudioPlayer();
  final HomeController _controller = HomeController();
  final LocalStorage _storage = LocalStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://avuxo-backend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  late final DriverRideManager _rideManager;
  late final DriverTrackingManager _trackingManager;
  late final DriverSocketManager _socketManager;
  late final DriverAccountManager _accountManager;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;

  Map<String, dynamic>? currentRide;
  String? currentRideId;

  Map<String, dynamic> _driverProfile = {};
  final List<Map<String, dynamic>> chatMessages = [];

  bool _socketActive = false;
  bool _socketConnecting = false;
  bool _notifyingRide = false;
  bool _rideActionLoading = false;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-11.433865, -61.456665),
    zoom: 15.5,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();

    _rideManager = DriverRideManager(
      dio: _dio,
      storage: _storage,
    );

    _trackingManager = DriverTrackingManager();

    _socketManager = DriverSocketManager(
      dio: _dio,
      storage: _storage,
      controller: _controller,
    );

    _accountManager = DriverAccountManager(
      dio: _dio,
      storage: _storage,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadLocation();
    await _loadDriverProfile();
    await _restoreRide();
    _startBlockCheck();
  }

  @override
  void dispose() {
    _accountManager.dispose();
    _socketManager.dispose();
    _trackingManager.dispose();
    _mapController?.dispose();
    _controller.dispose();
    _rideAudio.dispose();
    SocketService.instance.dispose();
    super.dispose();
  }

  String _txt(dynamic value, String fallback) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  double _num(dynamic value) {
    return double.tryParse('${value ?? 0}') ?? 0;
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

  void _saveCurrentRide(Map<String, dynamic> ride) {
    currentRide = ride;

    final id = _extractRideId(ride);

    if (id != null) {
      currentRideId = id;
      _storage.saveCurrentRideId(id);
      SocketService.instance.joinRide(id);
    }
  }

  void _clearRide() {
    currentRide = null;
    currentRideId = null;
    chatMessages.clear();
    _polylines.clear();
    _storage.clearCurrentRideId();
    SocketService.instance.clearCurrentRide();
  }

  Map<String, dynamic> get _passenger {
    final passenger = currentRide?['passenger'];
    if (passenger is Map) {
      return Map<String, dynamic>.from(passenger);
    }
    return {};
  }

  String get passengerName {
    return _txt(
      currentRide?['passengerName'] ??
          _passenger['fullName'] ??
          _passenger['name'],
      'Passageiro',
    );
  }

  String get pickupName {
    return _txt(
      currentRide?['originName'] ?? currentRide?['pickupAddress'],
      'Origem',
    );
  }

  String get destinationName {
    return _txt(
      currentRide?['destinationName'] ??
          currentRide?['destinationLabel'] ??
          currentRide?['destinationAddress'],
      'Destino',
    );
  }

  double get ridePrice {
    return _num(
      currentRide?['price'] ?? currentRide?['fare'] ?? currentRide?['total'],
    );
  }

  String get rideDistance {
    return _txt(currentRide?['distanceText'], '--');
  }

  String get rideEta {
    return _txt(currentRide?['eta'], '--');
  }

  LatLng get pickupLatLng {
    return LatLng(
      _num(currentRide?['originLat'] ?? currentRide?['pickupLat']),
      _num(currentRide?['originLng'] ?? currentRide?['pickupLng']),
    );
  }

  LatLng get destinationLatLng {
    return LatLng(
      _num(currentRide?['destLat'] ?? currentRide?['destinationLat']),
      _num(currentRide?['destLng'] ?? currentRide?['destinationLng']),
    );
  }

  Future<void> _restoreRide() async {
    final savedRideId = await _storage.getCurrentRideId();

    if (savedRideId == null || savedRideId.trim().isEmpty) return;

    currentRideId = savedRideId.trim();

    try {
      final response = await _dio.get('/ride/$currentRideId');
      final data = response.data;

      if (data is! Map) return;

      final ride = data['ride'] ?? data['data'];

      if (ride is! Map) return;

      final restoredRide = Map<String, dynamic>.from(ride);
      final status = '${restoredRide['status'] ?? ''}';
      final rideId = _extractRideId(restoredRide);

      if (rideId == null) return;

      if (!mounted) return;

      setState(() {
        _saveCurrentRide(restoredRide);

        if (status == 'pending' || status == 'searching') {
          _controller.restoreRide(
            rideId: rideId,
            state: DriverTripState.incomingRide,
          );
        } else if (status == 'accepted') {
          _controller.restoreRide(
            rideId: rideId,
            state: DriverTripState.accepted,
          );
        } else if (status == 'arriving' || status == 'arrived') {
          _controller.restoreRide(
            rideId: rideId,
            state: DriverTripState.arriving,
          );
        } else if (status == 'in_progress' || status == 'started') {
          _controller.restoreRide(
            rideId: rideId,
            state: DriverTripState.inProgress,
          );
        } else {
          _clearRide();
          _controller.resetTrip();
        }
      });
    } catch (_) {}
  }

  Future<void> _loadDriverProfile() async {
    final profile = await _accountManager.loadDriverProfile();

    if (!mounted) return;

    setState(() {
      _driverProfile = profile;
    });
  }

  void _startBlockCheck() {
    _accountManager.startBlockCheck(
      onBlocked: (_) {
        if (!mounted) return;

        _controller.goOffline();
        _clearRide();
        _socketManager.disconnect();
        _socketActive = false;
        _socketConnecting = false;

        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF0B1117),
            content: Text(
              'Sua conta foi bloqueada pelo administrador.',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthGate(),
          ),
          (_) => false,
        );
      },
    );
  }

  Future<void> _connectSocket() async {
    if (_socketActive || _socketConnecting) return;

    _socketConnecting = true;

    try {
      await _socketManager.connect(
        currentRideId: currentRideId,
        onRideAvailable: (ride) async {
          if (!mounted) return;
          if (!_controller.isOnline) return;
          if (_controller.hasActiveRide) return;

          final rideId = _extractRideId(ride);
          if (rideId == null) return;

          await _notifyIncomingRide();

          if (!mounted) return;

          setState(() {
            _saveCurrentRide(ride);
            _controller.receiveRide(rideId);
            _polylines.clear();
          });
        },
        onRideUpdate: (ride) {
          if (!mounted) return;

          final rideId = _extractRideId(ride);
          final status = '${ride['status'] ?? ''}';

          setState(() {
            _saveCurrentRide(ride);

            if ((status == 'pending' || status == 'searching') &&
                _controller.isOnline &&
                rideId != null) {
              _controller.receiveRide(rideId);
            }

            if (status == 'accepted') {
              _controller.acceptRide(rideId);
            }

            if (status == 'arriving' || status == 'arrived') {
              _controller.arrivePassenger();
            }

            if (status == 'in_progress' || status == 'started') {
              _controller.startTrip();
            }

            if (status == 'finished') {
              _controller.finishTrip();
              _polylines.clear();
            }

            if (status == 'cancelled' ||
                status == 'canceled' ||
                status == 'declined') {
              _controller.resetTrip();
              _clearRide();
            }
          });
        },
        onChatUpdated: (messages) {
          if (!mounted) return;

          setState(() {
            chatMessages
              ..clear()
              ..addAll(messages);
          });
        },
      );

      _socketActive = true;
    } finally {
      _socketConnecting = false;
    }
  }

  void _startRidePolling() {
    _socketManager.startRidePolling(
      getCurrentRideId: () => currentRideId,
      onRideFound: (ride) async {
        if (!mounted) return;
        if (_controller.hasActiveRide) return;

        final rideId = _extractRideId(ride);
        if (rideId == null) return;

        await _notifyIncomingRide();

        if (!mounted) return;

        setState(() {
          _saveCurrentRide(ride);
          _controller.receiveRide(rideId);
          _polylines.clear();
        });
      },
    );
  }

  void _stopRidePolling() {
    _socketManager.stopRidePolling();
  }

  Future<void> _loadLocation() async {
    try {
      await _trackingManager.loadCurrentLocation(
        mapController: _mapController,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _startLocationStream() async {
    await _trackingManager.startLocationStream(
      shouldSendLocation: () =>
          _controller.rideAccepted ||
          _controller.arriving ||
          _controller.inProgress,
      getRideId: () => currentRideId,
      onLocationUpdated: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _stopLocationStream() async {
    await _trackingManager.stopLocationStream();
  }

  void _sendCurrentLocationToPassenger() {
    _trackingManager.sendLocationToPassenger(
      rideId: currentRideId,
    );
  }

  Future<void> _toggleOnline() async {
    if (_rideActionLoading) return;

    HapticFeedback.mediumImpact();

    if (_controller.isOffline) {
      await _storage.saveOnlineStatus(true);

      if (!mounted) return;

      setState(() {
        _controller.goOnline();
        _polylines.clear();
      });

      await _connectSocket();
      await _startLocationStream();
      _startRidePolling();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF067A36),
          content: Text(
            'Você está ONLINE e recebendo corridas.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

      return;
    }

    await _storage.saveOnlineStatus(false);

    if (!mounted) return;

    setState(() {
      _controller.goOffline();
      _clearRide();
      _polylines.clear();
    });

    _socketManager.disconnect();
    _socketActive = false;
    _socketConnecting = false;
    await _stopLocationStream();
    _stopRidePolling();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        content: Text(
          'Você está OFFLINE e não receberá corridas.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _notifyIncomingRide() async {
    if (_notifyingRide) return;

    _notifyingRide = true;

    try {
      for (int i = 0; i < 4; i++) {
        if (!mounted) return;

        HapticFeedback.heavyImpact();
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(const Duration(milliseconds: 350));
      }
    } finally {
      _notifyingRide = false;
    }
  }

  void _drawRoute({
    required LatLng from,
    required LatLng to,
  }) {
    final route = _trackingManager.buildSimpleRoute(
      from: from,
      to: to,
    );

    if (route == null) return;

    setState(() {
      _polylines
        ..clear()
        ..add(route);
    });
  }

  Future<void> _acceptRide() async {
    if (_rideActionLoading) return;

    final rideId = currentRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    _rideActionLoading = true;

    await _rideAudio.stop();
    await _rideAudio.setReleaseMode(ReleaseMode.release);

    final current = _trackingManager.fallbackLatLng(_initialPosition.target);

    try {
      await _rideManager.acceptRide(
        rideId: rideId,
        driverProfile: _driverProfile,
        currentPosition: current,
        onSuccess: () {
          _stopRidePolling();
          _sendCurrentLocationToPassenger();

          _drawRoute(
            from: current,
            to: pickupLatLng,
          );

          if (!mounted) return;

          setState(() {
            _controller.acceptRide(rideId);
          });
        },
      );
    } catch (e) {
      debugPrint('Erro ao aceitar corrida: $e');
    } finally {
      _rideActionLoading = false;
    }
  }

  Future<void> _declineRide() async {
    if (_rideActionLoading) return;

    final rideId = currentRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    _rideActionLoading = true;

    await _rideAudio.stop();
    await _rideAudio.setReleaseMode(ReleaseMode.release);

    try {
      await _rideManager.declineRide(
        rideId: rideId,
        onSuccess: () {
          if (!mounted) return;

          setState(() {
            _controller.declineRide();
            _clearRide();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
              content: Text(
                'Corrida recusada.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Erro ao recusar corrida: $e');
    } finally {
      _rideActionLoading = false;
    }
  }

  Future<void> _arrivedPassenger() async {
    if (_rideActionLoading) return;

    final rideId = currentRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    _rideActionLoading = true;

    try {
      await _rideManager.arrivedPassenger(
        rideId: rideId,
        onSuccess: () {
          if (!mounted) return;

          setState(() {
            _controller.arrivePassenger();
          });
        },
      );
    } catch (e) {
      debugPrint('Erro ao marcar chegada: $e');
    } finally {
      _rideActionLoading = false;
    }
  }

  Future<void> _startTrip() async {
    if (_rideActionLoading) return;

    final rideId = currentRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    _rideActionLoading = true;

    try {
      await _rideManager.startTrip(
        rideId: rideId,
        onSuccess: () {
          _drawRoute(
            from: pickupLatLng,
            to: destinationLatLng,
          );

          if (!mounted) return;

          setState(() {
            _controller.startTrip();
          });
        },
      );
    } catch (e) {
      debugPrint('Erro ao iniciar corrida: $e');
    } finally {
      _rideActionLoading = false;
    }
  }

  Future<void> _finishTrip() async {
    if (_rideActionLoading) return;

    final rideId = currentRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    _rideActionLoading = true;

    try {
      await _rideManager.finishTrip(
        rideId: rideId,
        onSuccess: () {
          if (!mounted) return;

          setState(() {
            _controller.finishTrip();
            _polylines.clear();
          });
        },
      );
    } catch (e) {
      debugPrint('Erro ao finalizar corrida: $e');
    } finally {
      _rideActionLoading = false;
    }
  }

  Future<void> _sendRating() async {
    HapticFeedback.mediumImpact();

    await _storage.saveOnlineStatus(true);

    if (!mounted) return;

    setState(() {
      _controller.resetTrip();
      _clearRide();
    });

    await _connectSocket();
    _startRidePolling();
  }

  void _openChat() {
    if (currentRideId == null || currentRideId!.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    _socketManager.requestChat(currentRideId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DriverRideChatSheet(
          messages: chatMessages,
          onSend: (text) {
            final clean = text.trim();
            if (clean.isEmpty) return;

            SocketService.instance.sendDriverChatMessage(
              clean,
              rideId: currentRideId,
            );
          },
        );
      },
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      trafficEnabled: false,
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) async {
        _mapController = controller;
        await controller.setMapStyle(null);
        await _loadLocation();
      },
    );
  }

  Widget _buildTopStatus() {
    final top = MediaQuery.of(context).padding.top;

    return Positioned(
      top: top + 14,
      left: 18,
      right: 18,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'AVU',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'X',
                    style: TextStyle(
                      color: avuxoGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'O',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: _controller.isOnline
                    ? const Color(0xFFE8FFF2)
                    : const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _controller.isOnline
                    ? 'MOTORISTA ONLINE'
                    : 'MOTORISTA OFFLINE',
                style: TextStyle(
                  color: _controller.isOnline
                      ? const Color(0xFF067A36)
                      : const Color(0xFFC62828),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOnlineButton() {
    if (_controller.hasIncomingRide ||
        _controller.rideAccepted ||
        _controller.arriving ||
        _controller.inProgress ||
        _controller.finished) {
      return const SizedBox.shrink();
    }

    final bottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 22,
      right: 22,
      bottom: bottom + 24,
      child: GestureDetector(
        onTap: _toggleOnline,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _controller.isOnline ? Colors.black : avuxoGreen,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            _controller.isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
            style: TextStyle(
              color: _controller.isOnline ? Colors.white : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideRequestOverlay() {
    if (!_controller.hasIncomingRide || currentRide == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.70),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 30,
              ),
              child: RideRequestCard(
                passengerName: passengerName,
                pickup: pickupName,
                destination: destinationName,
                price: ridePrice,
                distance: rideDistance,
                eta: rideEta,
                onAccept: _acceptRide,
                onDecline: _declineRide,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedTripPanel() {
    if (!_controller.rideAccepted) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RideProgressTimeline(currentStep: 0),
          const SizedBox(height: 14),
          _darkPanel(
            title: 'A caminho do passageiro',
            subtitle: pickupName,
            buttonText: 'CHEGUEI',
            icon: Icons.location_on_rounded,
            onPressed: _arrivedPassenger,
          ),
        ],
      ),
    );
  }

  Widget _buildArrivedPanel() {
    if (!_controller.arriving) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RideProgressTimeline(currentStep: 1),
          const SizedBox(height: 14),
          _darkPanel(
            title: 'Passageiro localizado',
            subtitle: 'Agora inicie a corrida quando o passageiro entrar.',
            buttonText: 'INICIAR CORRIDA',
            icon: Icons.play_arrow_rounded,
            onPressed: _startTrip,
          ),
        ],
      ),
    );
  }

  Widget _darkPanel({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1117).withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: avuxoGreen.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: avuxoGreen.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: avuxoGreen,
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(icon, color: Colors.black),
                    label: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: avuxoGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _openChat,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: avuxoGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripRunningPanel() {
    if (!_controller.inProgress) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RideProgressTimeline(currentStep: 2),
          const SizedBox(height: 14),
          TripRunningCard(
            passengerName: passengerName,
            destination: destinationName,
            price: 'R\$ ${ridePrice.toStringAsFixed(2).replaceAll('.', ',')}',
            onFinish: _finishTrip,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChatButton() {
    if (!_controller.rideAccepted &&
        !_controller.arriving &&
        !_controller.inProgress) {
      return const SizedBox.shrink();
    }

    final bottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      right: 18,
      bottom: bottom + 130,
      child: DriverChatButton(
        unreadCount: 0,
        onTap: _openChat,
      ),
    );
  }

  Widget _buildRatingCard() {
    if (!_controller.finished) {
      return const SizedBox.shrink();
    }

    final bottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 18,
      right: 18,
      bottom: bottom + 18,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Avalie o passageiro',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Como foi sua experiência nessa corrida?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.56),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (_) => const Icon(
                  Icons.star_rounded,
                  color: Colors.black,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _sendRating,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ENVIAR AVALIAÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DriverSideMenu(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopStatus(),
          _buildBottomOnlineButton(),
          _buildRideRequestOverlay(),
          _buildAcceptedTripPanel(),
          _buildArrivedPanel(),
          _buildTripRunningPanel(),
          _buildFloatingChatButton(),
          _buildRatingCard(),
        ],
      ),
    );
  }
}