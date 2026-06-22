import 'dart:ui';

import 'package:flutter/material.dart';

class DriverMapStatusPanel extends StatelessWidget {
  const DriverMapStatusPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.online,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool online;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeTitle {
    final value = title.trim();

    if (value.isEmpty || value == 'null') {
      return 'AVUXO';
    }

    return value;
  }

  String get safeSubtitle {
    final value = subtitle.trim();

    if (value.isEmpty || value == 'null') {
      return 'Aguardando informações';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.92),
              borderRadius:
                  BorderRadius.circular(30),
              border: Border.all(
                color: online
                    ? avuxoGreen.withOpacity(0.16)
                    : Colors.white10,
              ),
              boxShadow: [
                BoxShadow(
                  color: online
                      ? avuxoGreen.withOpacity(0.06)
                      : Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: online
                        ? avuxoGreen.withOpacity(0.10)
                        : Colors.white10,
                    border: Border.all(
                      color: online
                          ? avuxoGreen.withOpacity(
                              0.24,
                            )
                          : Colors.white10,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: online
                        ? avuxoGreen
                        : Colors.white38,
                    size: 32,
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
                        safeTitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        safeSubtitle,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.60),
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 300),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: online
                        ? avuxoGreen
                        : Colors.white24,
                    boxShadow: online
                        ? [
                            BoxShadow(
                              color: avuxoGreen
                                  .withOpacity(
                                0.80,
                              ),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
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