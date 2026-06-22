import 'dart:ui';

import 'package:flutter/material.dart';

class DriverMapButtons extends StatelessWidget {
  const DriverMapButtons({
    super.key,
    required this.onMyLocation,
    required this.onCenterRide,
  });

  final VoidCallback onMyLocation;
  final VoidCallback onCenterRide;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            icon: Icons.my_location_rounded,
            onTap: onMyLocation,
          ),
          const SizedBox(height: 14),
          _button(
            icon: Icons.route_rounded,
            onTap: onCenterRide,
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1117)
                    .withOpacity(0.88),
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color:
                      avuxoGreen.withOpacity(0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        avuxoGreen.withOpacity(0.05),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: avuxoGreen,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
