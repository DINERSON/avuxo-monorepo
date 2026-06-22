import 'dart:ui';

import 'package:flutter/material.dart';

class DriverNotificationBanner extends StatelessWidget {
  const DriverNotificationBanner({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

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
      'Notificação',
    );

    final safeMessage = _safeText(
      message,
      'Nova atualização disponível.',
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: avuxoGreen.withAlpha(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(18),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(26),
                    border: Border.all(
                      color: avuxoGreen.withAlpha(61),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: avuxoGreen,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        safeTitle,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        safeMessage,
                        maxLines: 4,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white
                              .withAlpha(160),
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
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