import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/auth/services/auth_repository.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/ride/data/ride_repository.dart';
import '../../features/ride/domain/ride_models.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../../shared/models/common_models.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(localStorageProvider);
  final token = await storage.getToken();
  final api = ref.read(apiClientProvider);
  api.setToken(token);
});

final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    apiClient: ref.read(apiClientProvider),
  ),
);

final rideRepositoryProvider = Provider<RideRepository>(
  (ref) => RideRepository(
    apiClient: ref.read(apiClientProvider),
    placesApiKey: AppConstants.googlePlacesApiKey,
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.read(apiClientProvider)),
);

class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.loading = false,
    this.error,
    this.verificationId,
    this.phoneDraft,
  });

  final UserProfile? user;
  final String? token;
  final bool loading;
  final String? error;
  final String? verificationId;
  final String? phoneDraft;

  bool get isLoggedIn => user != null && (token?.isNotEmpty ?? false);

  AuthState copyWith({
    UserProfile? user,
    String? token,
    bool? loading,
    String? error,
    String? verificationId,
    String? phoneDraft,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      verificationId: verificationId ?? this.verificationId,
      phoneDraft: phoneDraft ?? this.phoneDraft,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _loadPersisted();
  }

  final Ref _ref;

  String _handleError(dynamic e) {
    try {
      return e.toString();
    } catch (_) {
      return 'Erro desconhecido';
    }
  }

  Future<void> _loadPersisted() async {
    final storage = _ref.read(localStorageProvider);
    final user = await storage.getUser();
    final token = await storage.getToken();

    if (user != null && token != null) {
      _ref.read(apiClientProvider).setToken(token);
      state = state.copyWith(user: user, token: token);
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      await _ref.read(authRepositoryProvider).registerPassenger(
            name: name,
            phone: phone,
            email: email,
          );

      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _handleError(e),
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      loading: true,
      phoneDraft: phone,
      clearError: true,
    );

    try {
      await _ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            onCodeSent: (id, _) {
              state = state.copyWith(
                verificationId: id.toString(),
                loading: false,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _handleError(e),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    final verificationId = state.verificationId;
    final phone = state.phoneDraft;

    if (verificationId == null || phone == null) {
      state = state.copyWith(
        loading: false,
        error: 'Envie o OTP primeiro.',
      );
      return;
    }

    state = state.copyWith(loading: true, clearError: true);

    try {
      final result = await _ref.read(authRepositoryProvider).verifyOtp(
            verificationId: verificationId.toString(),
            otp: otp.toString(),
            phone: phone.toString(),
          );

      _ref.read(apiClientProvider).setToken(result.$1);
      await _ref.read(localStorageProvider).saveAuth(result.$1, result.$2);

      state = state.copyWith(
        loading: false,
        user: result.$2,
        token: result.$1,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _handleError(e),
      );
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    await _ref.read(localStorageProvider).clearAuth();
    _ref.read(apiClientProvider).setToken(null);
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class HomeRideState {
  const HomeRideState({
    this.currentLocation,
    this.pickup,
    this.destination,
    this.route = const <LatLng>[],
    this.estimatedFare = 0,
    this.loading = false,
    this.error,
    this.activeRide,
    this.pickupSuggestions = const <PlaceSuggestion>[],
    this.destinationSuggestions = const <PlaceSuggestion>[],
  });

  final Position? currentLocation;
  final List<LatLng> route;
  final double estimatedFare;
  final bool loading;
  final String? error;
  final Coordinate? pickup;
  final Coordinate? destination;
  final Ride? activeRide;
  final List<PlaceSuggestion> pickupSuggestions;
  final List<PlaceSuggestion> destinationSuggestions;

  HomeRideState copyWith({
    Position? currentLocation,
    Coordinate? pickup,
    Coordinate? destination,
    List<LatLng>? route,
    double? estimatedFare,
    bool? loading,
    String? error,
    Ride? activeRide,
    List<PlaceSuggestion>? pickupSuggestions,
    List<PlaceSuggestion>? destinationSuggestions,
    bool clearError = false,
  }) {
    return HomeRideState(
      currentLocation: currentLocation ?? this.currentLocation,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      route: route ?? this.route,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      activeRide: activeRide ?? this.activeRide,
      pickupSuggestions: pickupSuggestions ?? this.pickupSuggestions,
      destinationSuggestions:
          destinationSuggestions ?? this.destinationSuggestions,
    );
  }
}

class HomeRideNotifier extends StateNotifier<HomeRideState> {
  HomeRideNotifier(this._ref) : super(const HomeRideState());

  final Ref _ref;

  Future<void> initCurrentLocation() async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        state = state.copyWith(
          loading: false,
          error: 'Location service disabled',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        state = state.copyWith(
          loading: false,
          error: 'Location permission denied',
        );
        return;
      }

      final current = await Geolocator.getCurrentPosition();

      final pickup = Coordinate(
        lat: current.latitude,
        lng: current.longitude,
        address: 'Current location',
      );

      state = state.copyWith(
        currentLocation: current,
        pickup: pickup,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchPickup(String input) async {
    final items = await _ref.read(rideRepositoryProvider).autocomplete(input);
    state = state.copyWith(pickupSuggestions: items);
  }

  Future<void> searchDestination(String input) async {
    final items = await _ref.read(rideRepositoryProvider).autocomplete(input);
    state = state.copyWith(destinationSuggestions: items);
  }

  Future<void> selectPickup(PlaceSuggestion suggestion) async {
    final location =
        await _ref.read(rideRepositoryProvider).placeDetails(suggestion.placeId);

    state = state.copyWith(
      pickup: location,
      pickupSuggestions: const <PlaceSuggestion>[],
    );

    await _updateRouteAndFare();
  }

  Future<void> selectDestination(PlaceSuggestion suggestion) async {
    final location =
        await _ref.read(rideRepositoryProvider).placeDetails(suggestion.placeId);

    state = state.copyWith(
      destination: location,
      destinationSuggestions: const <PlaceSuggestion>[],
    );

    await _updateRouteAndFare();
  }

  Future<void> _updateRouteAndFare() async {
    final pickup = state.pickup;
    final destination = state.destination;

    if (pickup == null || destination == null) return;

    final route = await _ref.read(rideRepositoryProvider).routePreview(
          from: pickup,
          to: destination,
        );

    final distanceKm = Geolocator.distanceBetween(
          pickup.lat,
          pickup.lng,
          destination.lat,
          destination.lng,
        ) /
        1000.0;

    final fare = 5.0 + (distanceKm * 2.5);

    state = state.copyWith(
      route: route,
      estimatedFare: fare,
    );
  }

  Future<void> requestRide() async {
    final pickup = state.pickup;
    final destination = state.destination;

    if (pickup == null || destination == null) return;

    state = state.copyWith(loading: true, clearError: true);

    try {
      final ride = await _ref.read(rideRepositoryProvider).requestRide(
            pickup: pickup,
            destination: destination,
          );

      state = state.copyWith(
        activeRide: ride,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}

final homeRideProvider = StateNotifierProvider<HomeRideNotifier, HomeRideState>(
  (ref) => HomeRideNotifier(ref),
);

final rideStatusStreamProvider = StreamProvider.family<Ride, String>(
  (ref, rideId) => ref.read(rideRepositoryProvider).pollRideStatus(rideId),
);

final rideHistoryProvider = FutureProvider<RideHistoryPage>(
  (ref) => ref.read(rideRepositoryProvider).getRideHistory(),
);

final profileProvider = FutureProvider<UserProfile>(
  (ref) => ref.read(profileRepositoryProvider).getMe(),
);
