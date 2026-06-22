import 'package:flutter/material.dart';

class DriverStatsRow extends StatelessWidget {
  const DriverStatsRow({
    super.key,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.rating,
  });

  final String acceptanceRate;
  final String cancellationRate;
  final String rating;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeValue(
    String value,
    String fallback,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(
            child: _StatsCard(
              icon: Icons.check_circle,
              title: 'Aceitação',
              value: _safeValue(
                acceptanceRate,
                '0%',
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: _StatsCard(
              icon: Icons.cancel_rounded,
              title: 'Cancel.',
              value: _safeValue(
                cancellationRate,
                '0%',
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: _StatsCard(
              icon: Icons.star_rounded,
              title: 'Nota',
              value: _safeValue(
                rating,
                '0.0',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xEB0B1117),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: avuxoGreen.withAlpha(26),
        ),
        boxShadow: [
          BoxShadow(
            color: avuxoGreen.withAlpha(12),
            blurRadius: 12,
          ),
        ],
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 6),

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
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}