import 'dart:ui';

import 'package:flutter/material.dart';

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard({
    super.key,
    required this.address,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String address;
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeAddress {
    final value = address.trim();

    if (value.isEmpty || value == 'null') {
      return 'Endereço não informado';
    }

    return value;
  }

  String get safeTitle {
    final value = title.trim();

    if (value.isEmpty || value == 'null') {
      return 'Local';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1117)
                      .withOpacity(0.88),
                  borderRadius:
                      BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      0.05,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          avuxoGreen.withOpacity(
                        0.05,
                      ),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            iconColor.withOpacity(
                          0.10,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            safeTitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(
                                0.45,
                              ),
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            safeAddress,
                            maxLines: 3,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .w700,
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
            ),
          ),
        ),
      ),
    );
  }
}