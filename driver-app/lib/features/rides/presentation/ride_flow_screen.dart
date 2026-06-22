import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/location/location_service.dart';
import '../../home/data/driver_status_repository.dart';
import '../data/ride_repository.dart';

class RideFlowScreen extends ConsumerStatefulWidget {
  const RideFlowScreen({
    super.key,
    required this.ride,
    required this.driverId,
  });

  final Map<String, dynamic> ride;
  final String driverId;

  @override
  ConsumerState<RideFlowScreen> createState() =>
      _RideFlowScreenState();
}

class _RideFlowScreenState
    extends ConsumerState<RideFlowScreen> {
  final LocationService _loc =
      LocationService();

  StreamSubscription<Position>? _sub;

  String stage = 'driver_arriving';

  bool _updatingStatus = false;

  DateTime? _lastLocationSent;

  late final String rideId;

  @override
  void initState() {
    super.initState();

    rideId =
        '${widget.ride['id'] ?? widget.ride['rideId'] ?? ''}'
            .trim();

    _startTracking();

    if (rideId.isNotEmpty) {
      _update('driver_arriving');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  double _toDouble(
    dynamic value,
    double fallback,
  ) {
    if (value == null) {
      return fallback;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  void _startTracking() {
    if (rideId.isEmpty) return;

    _sub = _loc.stream().listen(
      (p) async {
        try {
          final now = DateTime.now();

          if (_lastLocationSent != null &&
              now
                      .difference(
                        _lastLocationSent!,
                      )
                      .inSeconds <
                  3) {
            return;
          }

          _lastLocationSent = now;

          await ref
              .read(
                driverStatusRepositoryProvider,
              )
              .sendLocationUpdate(
                lat: p.latitude,
                lng: p.longitude,
                rideId: rideId,
              );
        } catch (_) {}
      },
      onError: (_) {},
    );
  }

  Future<void> _update(
    String newStatus,
  ) async {
    if (_updatingStatus) return;

    if (rideId.isEmpty) return;

    if (stage == newStatus) return;

    _updatingStatus = true;

    try {
      await ref
          .read(rideRepositoryProvider)
          .updateRideStatus(
            rideId: rideId,
            status: newStatus,
          );

      if (!mounted) return;

      setState(() {
        stage = newStatus;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Falha ao atualizar status da corrida.',
            ),
          ),
        );
    } finally {
      _updatingStatus = false;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final pLat = _toDouble(
      widget.ride['pickup_lat'],
      -23.5505,
    );

    final pLng = _toDouble(
      widget.ride['pickup_lng'],
      -46.6333,
    );

    final dLat = _toDouble(
      widget.ride['destination_lat'],
      -23.561,
    );

    final dLng = _toDouble(
      widget.ride['destination_lng'],
      -46.645,
    );

    final target =
        stage == 'in_progress'
            ? LatLng(dLat, dLng)
            : LatLng(pLat, pLng);

    final markers = {
      Marker(
        markerId: const MarkerId(
          'target',
        ),
        position: target,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fluxo da corrida',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(
                target: target,
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: markers,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Status atual: $stage',
                ),
                const SizedBox(height: 8),
                if (stage ==
                    'driver_arriving')
                  FilledButton(
                    onPressed:
                        _updatingStatus
                            ? null
                            : () => _update(
                                  'in_progress',
                                ),
                    child: const Text(
                      'Cheguei ao embarque / Iniciar viagem',
                    ),
                  ),
                if (stage ==
                    'in_progress')
                  FilledButton(
                    onPressed:
                        _updatingStatus
                            ? null
                            : () async {
                                await _update(
                                  'completed',
                                );

                                if (!mounted) {
                                  return;
                                }

                                Navigator.pop(
                                  context,
                                );
                              },
                    child: const Text(
                      'Finalizar corrida',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}