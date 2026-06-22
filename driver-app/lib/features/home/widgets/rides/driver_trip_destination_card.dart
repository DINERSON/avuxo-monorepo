import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripDestinationCard extends StatelessWidget {
  const DriverTripDestinationCard({
    super.key,
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeAddress(
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
    final safePickup = _safeAddress(
      pickup,
      'Local de embarque não informado',
    );

    final safeDestination = _safeAddress(
      destination,
      'Destino não informado',
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: avuxoGreen.withAlpha(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LocationItem(
                  title: 'EMBARQUE',
                  address: safePickup,
                  icon: Icons.my_location_rounded,
                  color: avuxoGreen,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        width: 2,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(999),
                          color: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                ),

                _LocationItem(
                  title: 'DESTINO',
                  address: safeDestination,
                  icon: Icons.location_on_rounded,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  const _LocationItem({
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}