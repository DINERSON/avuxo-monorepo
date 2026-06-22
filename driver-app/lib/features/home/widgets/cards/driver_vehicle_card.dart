import 'dart:ui';

import 'package:flutter/material.dart';

class DriverVehicleCard extends StatelessWidget {
  const DriverVehicleCard({
    super.key,
    required this.vehicleName,
    required this.plate,
    required this.color,
    required this.category,
    this.vehicleImage,
  });

  final String vehicleName;
  final String plate;
  final String color;
  final String category;
  final String? vehicleImage;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safe(String value, String fallback) {
    final text = value.trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.92),
              borderRadius:
                  BorderRadius.circular(32),
              border: Border.all(
                color:
                    avuxoGreen.withOpacity(0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      avuxoGreen.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        color:
                            avuxoGreen.withOpacity(
                          0.10,
                        ),
                        border: Border.all(
                          color: avuxoGreen
                              .withOpacity(0.22),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        child: vehicleImage != null &&
                                vehicleImage!
                                    .trim()
                                    .isNotEmpty
                            ? Image.network(
                                vehicleImage!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) {
                                  return const Icon(
                                    Icons
                                        .directions_car_filled_rounded,
                                    color:
                                        avuxoGreen,
                                    size: 42,
                                  );
                                },
                              )
                            : const Icon(
                                Icons
                                    .directions_car_filled_rounded,
                                color:
                                    avuxoGreen,
                                size: 42,
                              ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            _safe(
                              vehicleName,
                              'Veículo',
                            ),
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            _safe(
                              category,
                              'Categoria',
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.60,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _info(
                        title: 'PLACA',
                        value: _safe(
                          plate,
                          '--',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _info(
                        title: 'COR',
                        value: _safe(
                          color,
                          '--',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.45),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}