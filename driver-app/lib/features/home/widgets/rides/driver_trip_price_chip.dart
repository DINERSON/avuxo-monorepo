import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripPriceChip extends StatelessWidget {
  const DriverTripPriceChip({
    super.key,
    required this.price,
    required this.highlight,
  });

  final String price;
  final bool highlight;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safePrice {
    final value = price.trim();

    if (value.isEmpty) {
      return 'R\$ 0,00';
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
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: highlight
                  ? avuxoGreen
                  : const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: highlight
                    ? avuxoGreen
                    : Colors.white12,
              ),
              boxShadow: [
                BoxShadow(
                  color: highlight
                      ? avuxoGreen.withAlpha(64)
                      : Colors.black26,
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attach_money_rounded,
                  color: highlight
                      ? Colors.black
                      : avuxoGreen,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    _safePrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: highlight
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
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