import 'package:flutter/material.dart';

class DriverStatusChip extends StatelessWidget {
  const DriverStatusChip({
    super.key,
    required this.label,
    required this.isActive,
    this.icon = Icons.bolt_rounded,
  });

  final String label;
  final bool isActive;
  final IconData icon;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safeLabel {
    final value = label.trim();

    if (value.isEmpty) {
      return 'STATUS';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0B1117),
          borderRadius:
              BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? avuxoGreen.withAlpha(70)
                : Colors.white12,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color:
                        avuxoGreen.withAlpha(24),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? avuxoGreen
                  : Colors.white38,
              size: 18,
            ),

            const SizedBox(width: 8),

            Flexible(
              child: Text(
                _safeLabel,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? avuxoGreen
                      : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}