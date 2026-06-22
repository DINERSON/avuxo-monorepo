import 'dart:ui';

import 'package:flutter/material.dart';

class DriverEmptyStateCard extends StatelessWidget {
  const DriverEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeText(
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
    final safeTitle = _safeText(
      title,
      'Nenhuma informação disponível',
    );

    final safeMessage = _safeText(
      message,
      'Não há dados para exibir no momento.',
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: avuxoGreen.withAlpha(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(26),
                    border: Border.all(
                      color: avuxoGreen.withAlpha(61),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(56),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: avuxoGreen,
                    size: 54,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  safeTitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  safeMessage,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.6,
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
