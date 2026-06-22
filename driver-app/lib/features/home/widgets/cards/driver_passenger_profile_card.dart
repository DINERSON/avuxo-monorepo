import 'dart:ui';

import 'package:flutter/material.dart';

class DriverPassengerProfileCard extends StatelessWidget {
  const DriverPassengerProfileCard({
    super.key,
    required this.name,
    required this.rating,
    required this.totalTrips,
    this.photoUrl,
  });

  final String name;
  final double rating;
  final int totalTrips;
  final String? photoUrl;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeName {
    final value = name.trim();

    if (value.isEmpty || value == 'null') {
      return 'Passageiro';
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

  int get safeTrips {
    if (totalTrips < 0) {
      return 0;
    }

    return totalTrips;
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
            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        avuxoGreen.withOpacity(0.10),
                    border: Border.all(
                      color: avuxoGreen
                          .withOpacity(0.24),
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
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        safeName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: avuxoGreen,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .star_rounded,
                                  color:
                                      Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  safeRating
                                      .toStringAsFixed(
                                    1,
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .black,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              '$safeTrips viagens',
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
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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