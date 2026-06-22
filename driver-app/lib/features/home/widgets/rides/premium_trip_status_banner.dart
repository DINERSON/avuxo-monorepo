import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumTripStatusBanner extends StatelessWidget {
  const PremiumTripStatusBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;

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
      'Status da corrida',
    );

    final safeSubtitle = _safeText(
      subtitle,
      'Aguardando atualização.',
    );

    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        opacity: active ? 1.0 : 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xEB0B1117),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: active
                      ? avuxoGreen.withAlpha(46)
                      : Colors.white12,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: avuxoGreen.withAlpha(20),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? avuxoGreen.withAlpha(26)
                          : Colors.white12,
                      border: Border.all(
                        color: active
                            ? avuxoGreen.withAlpha(61)
                            : Colors.white12,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: active
                          ? avuxoGreen
                          : Colors.white38,
                      size: 30,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          safeSubtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(155),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}