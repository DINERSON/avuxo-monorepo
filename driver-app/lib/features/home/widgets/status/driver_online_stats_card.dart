import 'dart:ui';

import 'package:flutter/material.dart';

class DriverOnlineStatsCard extends StatelessWidget {
  const DriverOnlineStatsCard({
    super.key,
    required this.totalTrips,
    required this.totalEarnings,
    required this.onlineHours,
  });

  final int totalTrips;
  final String totalEarnings;
  final String onlineHours;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeText(String value, String fallback) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }

  int get _safeTotalTrips {
    if (totalTrips < 0) {
      return 0;
    }

    return totalTrips;
  }

  @override
  Widget build(BuildContext context) {
    final safeEarnings = _safeText(totalEarnings, 'R\$ 0,00');
    final safeOnlineHours = _safeText(onlineHours, '0h');

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: avuxoGreen.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatsItem(
                    icon: Icons.route_rounded,
                    title: 'Viagens',
                    value: '$_safeTotalTrips',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatsItem(
                    icon: Icons.attach_money_rounded,
                    title: 'Ganhos',
                    value: safeEarnings,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatsItem(
                    icon: Icons.timer_rounded,
                    title: 'Online',
                    value: safeOnlineHours,
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

class _StatsItem extends StatelessWidget {
  const _StatsItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(11),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: avuxoGreen,
            size: 24,
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontWeight: FontWeight.w700,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}