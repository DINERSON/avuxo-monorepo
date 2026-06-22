import 'dart:ui';

import 'package:flutter/material.dart';

class DriverEtaChip extends StatelessWidget {
  const DriverEtaChip({
    super.key,
    required this.eta,
    required this.active,
    this.icon = Icons.timer_rounded,
  });

  final String eta;
  final bool active;
  final IconData icon;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safeEta {
    final value = eta.trim();

    if (value.isEmpty || value == 'null') {
      return '--';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117).withOpacity(0.90),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active
                    ? avuxoGreen.withOpacity(0.22)
                    : Colors.white10,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: avuxoGreen.withOpacity(0.10),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: active
                      ? avuxoGreen
                      : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _safeEta,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.4,
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