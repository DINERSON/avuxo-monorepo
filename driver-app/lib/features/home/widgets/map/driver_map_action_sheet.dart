import 'dart:ui';

import 'package:flutter/material.dart';

class DriverMapActionSheet extends StatelessWidget {
  const DriverMapActionSheet({
    super.key,
    required this.onCenter,
    required this.onLocation,
    required this.onCompass,
    required this.onLayers,
  });

  final VoidCallback onCenter;
  final VoidCallback onLocation;
  final VoidCallback onCompass;
  final VoidCallback onLayers;

  static const Color avuxoGreen = Color(0xFF24F877);

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
            padding: const EdgeInsets.all(18),
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
                _button(
                  icon:
                      Icons.center_focus_strong_rounded,
                  label: 'Centralizar',
                  onTap: onCenter,
                ),
                _button(
                  icon: Icons.my_location_rounded,
                  label: 'GPS',
                  onTap: onLocation,
                ),
                _button(
                  icon: Icons.explore_rounded,
                  label: 'Bússola',
                  onTap: onCompass,
                ),
                _button(
                  icon: Icons.layers_rounded,
                  label: 'Mapa',
                  onTap: onLayers,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.04,
                ),
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white
                      .withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: avuxoGreen,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                      fontSize: 11,
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