import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripRunningCard extends StatelessWidget {
  const TripRunningCard({
    super.key,
    required this.passengerName,
    required this.destination,
    required this.price,
    required this.onFinish,
  });

  final String passengerName;
  final String destination;
  final String price;
  final VoidCallback onFinish;

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

    final safeDestination = _safeText(
      destination,
      'Destino não informado',
    );

    final safePrice = _safeText(
      price,
      'R\$ 0,00',
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
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avuxoGreen.withAlpha(26),
                        border: Border.all(
                          color: avuxoGreen.withAlpha(61),
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: avuxoGreen,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            safePassengerName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'VIAGEM EM ANDAMENTO',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: avuxoGreen,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Flexible(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: avuxoGreen,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Text(
                          safePrice,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight:
                                FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius:
                        BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          Colors.white.withAlpha(13),
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
                          color:
                              Colors.red.withAlpha(26),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.redAccent,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESTINO',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color: Colors.white
                                    .withAlpha(115),
                                fontWeight:
                                    FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              safeDestination,
                              maxLines: 3,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onFinish();
                    },
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'FINALIZAR CORRIDA',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
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