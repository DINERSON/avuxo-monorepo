import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverArrivedCard extends StatelessWidget {
  const DriverArrivedCard({
    super.key,
    required this.passengerName,
    required this.pickupAddress,
    required this.onStartRide,
  });

  final String passengerName;
  final String pickupAddress;
  final VoidCallback onStartRide;

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

    final safePickupAddress = _safeText(
      pickupAddress,
      'Local de embarque não informado',
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
            padding: const EdgeInsets.all(24),
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
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(26),
                    border: Border.all(
                      color: avuxoGreen.withAlpha(61),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(56),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: avuxoGreen,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'VOCÊ CHEGOU\nAO PASSAGEIRO',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  safePassengerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withAlpha(13),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avuxoGreen.withAlpha(26),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: avuxoGreen,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOCAL DE EMBARQUE',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white
                                    .withAlpha(115),
                                fontWeight:
                                    FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              safePickupAddress,
                              maxLines: 3,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onStartRide();
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'INICIAR VIAGEM',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          avuxoGreen,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                      ),
                    ),
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