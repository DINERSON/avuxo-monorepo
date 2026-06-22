import 'dart:ui';

import 'package:flutter/material.dart';

class DriverNewRideCard extends StatelessWidget {
  const DriverNewRideCard({
    super.key,
    required this.passengerName,
    required this.distance,
    required this.price,
    required this.pickup,
    required this.destination,
  });

  final String passengerName;
  final String distance;
  final String price;
  final String pickup;
  final String destination;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeText(String value, String fallback) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    final safePassengerName =
        _safeText(passengerName, 'Passageiro');
    final safeDistance = _safeText(distance, 'Distância não informada');
    final safePrice = _safeText(price, 'R\$ 0,00');
    final safePickup = _safeText(pickup, 'Local de embarque não informado');
    final safeDestination =
        _safeText(destination, 'Destino não informado');

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF20B1117),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: avuxoGreen.withAlpha(56),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(26),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avuxoGreen.withAlpha(26),
                        border: Border.all(
                          color: avuxoGreen.withAlpha(61),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avuxoGreen.withAlpha(46),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: avuxoGreen,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'NOVA CORRIDA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: avuxoGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            safePassengerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: avuxoGreen,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          safePrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _LocationInfo(
                  title: 'EMBARQUE',
                  address: safePickup,
                  icon: Icons.my_location_rounded,
                  color: avuxoGreen,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        width: 2,
                        height: 32,
                        color: Colors.white12,
                      ),
                    ],
                  ),
                ),
                _LocationInfo(
                  title: 'DESTINO',
                  address: safeDestination,
                  icon: Icons.location_on_rounded,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withAlpha(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        color: avuxoGreen,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          safeDistance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  const _LocationInfo({
    required this.title,
    required this.address,
    required this.icon,
    required this.color,
  });

  final String title;
  final String address;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(26),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(115),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}