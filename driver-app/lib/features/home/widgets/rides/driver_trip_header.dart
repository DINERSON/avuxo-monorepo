import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripHeader extends StatelessWidget {
  const DriverTripHeader({
    super.key,
    required this.passengerName,
    required this.tripStatus,
    required this.distance,
  });

  final String passengerName;
  final String tripStatus;
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
    final safePassengerName = _safeText(
      passengerName,
      'Passageiro',
    );

    final safeTripStatus = _safeText(
      tripStatus,
      'EM CORRIDA',
    );

    final safeDistance = _safeText(
      distance,
      '-- km',
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
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(26),
                    border: Border.all(
                      color: avuxoGreen.withAlpha(61),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(56),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: avuxoGreen,
                    size: 36,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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

                      const SizedBox(height: 8),

                      Text(
                        safeTripStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: avuxoGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 110,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: avuxoGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(56),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        color: Colors.black,
                        size: 22,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        safeDistance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
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