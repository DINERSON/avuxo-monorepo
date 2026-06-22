import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverTopBar extends StatelessWidget {
  const DriverTopBar({
    super.key,
    required this.driverName,
    required this.rating,
    required this.onMenuTap,
  });

  final String driverName;
  final double rating;
  final VoidCallback onMenuTap;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safeDriverName {
    final value = driverName.trim();

    if (value.isEmpty) {
      return 'Motorista';
    }

    return value;
  }

  double get _safeRating {
    if (!rating.isFinite) {
      return 0.0;
    }

    if (rating < 0) {
      return 0.0;
    }

    if (rating > 5) {
      return 5.0;
    }

    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0B1117),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: avuxoGreen.withAlpha(30),
          ),
          boxShadow: [
            BoxShadow(
              color: avuxoGreen.withAlpha(15),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onMenuTap();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(15),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avuxoGreen.withAlpha(24),
                border: Border.all(
                  color: avuxoGreen.withAlpha(56),
                ),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: avuxoGreen,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AVUXO MOTORISTA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: avuxoGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _safeDriverName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: avuxoGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.black,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _safeRating.toStringAsFixed(1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}