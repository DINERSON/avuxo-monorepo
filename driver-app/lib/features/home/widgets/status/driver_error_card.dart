import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverErrorCard extends StatelessWidget {
  const DriverErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

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
      'Erro inesperado',
    );

    final safeMessage = _safeText(
      message,
      'Ocorreu uma falha temporária. Tente novamente.',
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
                color: Colors.redAccent.withAlpha(56),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withAlpha(30),
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
                    color: Colors.redAccent.withAlpha(26),
                    border: Border.all(
                      color: Colors.redAccent.withAlpha(61),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withAlpha(56),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
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
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onRetry();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'TENTAR NOVAMENTE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: avuxoGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
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