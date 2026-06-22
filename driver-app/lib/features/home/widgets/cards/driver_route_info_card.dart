import 'dart:ui';

import 'package:flutter/material.dart';

class DriverRouteInfoCard extends StatelessWidget {
  const DriverRouteInfoCard({
    super.key,
    required this.distance,
    required this.duration,
    required this.arrivalTime,
  });

  final String distance;
  final String duration;
  final String arrivalTime;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safe(String value) {
    final text = value.trim();

    if (text.isEmpty || text == 'null') {
      return '--';
    }

    return text;
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.92),
              borderRadius:
                  BorderRadius.circular(30),
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
                Expanded(
                  child: _item(
                    icon: Icons.route_rounded,
                    title: 'Distância',
                    value: _safe(distance),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _item(
                    icon: Icons.timer_rounded,
                    title: 'Duração',
                    value: _safe(duration),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _item(
                    icon:
                        Icons.access_time_filled_rounded,
                    title: 'Chegada',
                    value: _safe(arrivalTime),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: avuxoGreen,
            size: 24,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.50),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}