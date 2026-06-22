import 'dart:ui';

import 'package:flutter/material.dart';

class FinishedTripDialog extends StatelessWidget {
  const FinishedTripDialog({
    super.key,
    required this.passengerName,
    required this.price,
    required this.distance,
    required this.onClose,
  });

  final String passengerName;
  final String price;
  final String distance;
  final VoidCallback onClose;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safePassengerName {
    final value = passengerName.trim();

    if (value.isEmpty || value == 'null') {
      return 'Passageiro';
    }

    return value;
  }

  String get safePrice {
    final value = price.trim();

    if (value.isEmpty || value == 'null') {
      return 'R\$ 0,00';
    }

    return value;
  }

  String get safeDistance {
    final value = distance.trim();

    if (value.isEmpty || value == 'null') {
      return '--';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 24,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1117)
                    .withOpacity(0.94),
                borderRadius:
                    BorderRadius.circular(34),
                border: Border.all(
                  color:
                      avuxoGreen.withOpacity(0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        avuxoGreen.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          avuxoGreen.withOpacity(
                        0.10,
                      ),
                      border: Border.all(
                        color: avuxoGreen
                            .withOpacity(0.24),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: avuxoGreen,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'CORRIDA\nFINALIZADA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    safePassengerName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Colors.white.withOpacity(
                        0.65,
                      ),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(
                        0.04,
                      ),
                      borderRadius:
                          BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          safePrice,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: avuxoGreen,
                            fontSize: 36,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Valor recebido',
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(
                              0.55,
                            ),
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const Icon(
                              Icons.route_rounded,
                              color: avuxoGreen,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                safeDistance,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            avuxoGreen,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                        ),
                      ),
                      child: const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight:
                              FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}