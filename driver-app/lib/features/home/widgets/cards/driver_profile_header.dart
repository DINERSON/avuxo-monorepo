import 'dart:ui';

import 'package:flutter/material.dart';

class DriverProfileHeader extends StatelessWidget {
  const DriverProfileHeader({
    super.key,
    required this.driverName,
    required this.vehicleName,
    required this.rating,
    required this.online,
    this.photoUrl,
  });

  final String driverName;
  final String vehicleName;
  final double rating;
  final bool online;
  final String? photoUrl;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeDriverName {
    final value = driverName.trim();

    if (value.isEmpty || value == 'null') {
      return 'Motorista';
    }

    return value;
  }

  String get safeVehicleName {
    final value = vehicleName.trim();

    if (value.isEmpty || value == 'null') {
      return 'Veículo não informado';
    }

    return value;
  }

  double get safeRating {
    if (rating.isNaN) {
      return 5.0;
    }

    if (rating < 0) {
      return 0;
    }

    if (rating > 5) {
      return 5;
    }

    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.94),
              borderRadius:
                  BorderRadius.circular(34),
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
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            avuxoGreen.withOpacity(
                          0.10,
                        ),
                        border: Border.all(
                          color: avuxoGreen
                              .withOpacity(0.24),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: photoUrl != null &&
                                photoUrl!
                                    .trim()
                                    .isNotEmpty
                            ? Image.network(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) {
                                  return const Icon(
                                    Icons.person,
                                    color:
                                        avuxoGreen,
                                    size: 42,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                color: avuxoGreen,
                                size: 42,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: online
                              ? avuxoGreen
                              : Colors.white24,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          boxShadow: online
                              ? [
                                  BoxShadow(
                                    color:
                                        avuxoGreen
                                            .withOpacity(
                                      0.8,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        safeDriverName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        safeVehicleName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.60),
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: avuxoGreen,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              safeRating
                                  .toStringAsFixed(1),
                              style:
                                  const TextStyle(
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
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