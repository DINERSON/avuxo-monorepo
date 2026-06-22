import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EarningsCard extends StatelessWidget {
  const EarningsCard({
    super.key,
    required this.todayAmount,
    required this.ridesCount,
    required this.onlineTime,
  });

  final double todayAmount;
  final int ridesCount;
  final String onlineTime;

  static const Color avuxoGreen = Color(0xFF24F877);

  double get safeAmount {
    if (todayAmount.isNaN || todayAmount.isInfinite) {
      return 0;
    }

    if (todayAmount < 0) {
      return 0;
    }

    return todayAmount;
  }

  int get safeRides {
    if (ridesCount < 0) {
      return 0;
    }

    return ridesCount;
  }

  String get safeOnlineTime {
    final value = onlineTime.trim();

    if (value.isEmpty || value == 'null') {
      return '--';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(safeAmount);

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
                  .withOpacity(0.88),
              borderRadius:
                  BorderRadius.circular(30),
              border: Border.all(
                color:
                    avuxoGreen.withOpacity(0.12),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'GANHOS DE HOJE',
                  style: TextStyle(
                    color: avuxoGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  money,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        icon: Icons.local_taxi,
                        title: 'Corridas',
                        value: '$safeRides',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _infoBox(
                        icon:
                            Icons.access_time_filled,
                        title: 'Online',
                        value: safeOnlineTime,
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

  Widget _infoBox({
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
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.50),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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