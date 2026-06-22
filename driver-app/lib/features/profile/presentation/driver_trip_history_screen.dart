import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

class DriverTripHistoryScreen extends StatefulWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  State<DriverTripHistoryScreen> createState() =>
      _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState
    extends State<DriverTripHistoryScreen> {
  static const Color avuxoGreen =
      Color(0xFF24F877);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'https://avuxo-backend-production.up.railway.app',
      connectTimeout:
          const Duration(seconds: 12),
      receiveTimeout:
          const Duration(seconds: 12),
      validateStatus: (status) =>
          status != null && status < 500,
    ),
  );

  bool loading = true;
  bool _loadingTrips = false;

  String? error;

  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  void dispose() {
    dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadTrips() async {
    if (_loadingTrips) return;

    _loadingTrips = true;

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final phone =
          await LocalStorage().getPhone();

      if (!mounted) return;

      if (phone == null ||
          phone.trim().isEmpty) {
        setState(() {
          error =
              'Telefone do motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final normalizedPhone =
          phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final profileResponse =
          await dio.get(
        '/drivers/status/$normalizedPhone',
      );

      if (!mounted) return;

      final profileData =
          profileResponse.data;

      if (profileData is! Map ||
          profileData['found'] != true ||
          profileData['driver'] is! Map) {
        setState(() {
          error =
              'Motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final driverData =
          Map<String, dynamic>.from(
        profileData['driver'],
      );

      final driverId =
          '${driverData['id'] ?? ''}'
              .trim();

      if (driverId.isEmpty) {
        setState(() {
          error =
              'ID do motorista não veio do backend.';
          loading = false;
        });
        return;
      }

      final response =
          await dio.get(
        '/driver/trips/$driverId',
      );

      if (!mounted) return;

      final data = response.data;

      if (data is! Map ||
          data['success'] != true ||
          data['trips'] is! List) {
        setState(() {
          error =
              'Não foi possível carregar o histórico.';
          loading = false;
        });
        return;
      }
      final rawTrips = data['trips'] as List;

      final parsedTrips = rawTrips
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList(growable: false);

      setState(() {
        trips = parsedTrips;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Erro de conexão com o backend.';
        loading = false;
      });
    } finally {
      _loadingTrips = false;
    }
  }

  String _text(
    dynamic value, {
    String fallback = 'Não informado',
  }) {
    final text = '${value ?? ''}'.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  String _money(dynamic value) {
    final raw = '${value ?? ''}'
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();

    final number = double.tryParse(raw);

    if (number == null || !number.isFinite || number < 0) {
      return 'R\$ 0,00';
    }

    return 'R\$ ${number.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _date(dynamic value) {
    final raw = '${value ?? ''}'.trim();

    if (raw.isEmpty) {
      return 'Sem data';
    }

    final parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return raw;
    }

    final local = parsed.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month • $hour:$minute';
  }

  String _route(Map<String, dynamic> trip) {
    final origin = _text(
      trip['origin'] ?? trip['originName'],
      fallback: 'Origem',
    );

    final destination = _text(
      trip['destination'] ?? trip['destinationName'],
      fallback: 'Destino',
    );

    return '$origin → $destination';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Histórico de Corridas',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading || _loadingTrips
                ? null
                : _loadTrips,
            icon: const Icon(
              Icons.refresh,
              color: avuxoGreen,
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }
  Widget _body() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: avuxoGreen,
          strokeWidth: 2.8,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    if (trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você ainda não possui corridas finalizadas.',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        color: avuxoGreen,
        backgroundColor: const Color(0xFF141C25),
        onRefresh: _loadTrips,
        child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];

            return _TripCard(
              passenger: _text(
                trip['passenger'] ?? trip['passengerName'],
                fallback: 'Passageiro AVUXO',
              ),
              route: _route(trip),
              value: _money(
                trip['value'] ??
                    trip['total'] ??
                    trip['price'] ??
                    trip['fare'],
              ),
              date: _date(
                trip['date'] ??
                    trip['finishedAt'] ??
                    trip['updatedAt'] ??
                    trip['createdAt'],
              ),
              distance: _text(
                trip['distance'] ?? trip['distanceText'],
                fallback: '',
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.passenger,
    required this.route,
    required this.value,
    required this.date,
    required this.distance,
  });

  final String passenger;
  final String route;
  final String value;
  final String date;
  final String distance;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeText(
    String value,
    String fallback,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final safePassenger = _safeText(
      passenger,
      'Passageiro AVUXO',
    );

    final safeRoute = _safeText(
      route,
      'Origem → Destino',
    );

    final safeValue = _safeText(
      value,
      'R\$ 0,00',
    );

    final safeDate = _safeText(
      date,
      'Sem data',
    );

    final safeDistance = distance.trim();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141C25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withAlpha(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safePassenger,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              safeRoute,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (safeDistance.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                safeDistance,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    safeValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: avuxoGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    safeDate,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}