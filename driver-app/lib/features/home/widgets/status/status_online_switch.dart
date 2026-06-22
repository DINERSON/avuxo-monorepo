import 'package:flutter/material.dart';

class StatusOnlineSwitch extends StatelessWidget {
  const StatusOnlineSwitch({
    super.key,
    required this.isOnline,
    required this.onChanged,
  });

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0B1117),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isOnline
                ? avuxoGreen.withAlpha(46)
                : Colors.white12,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? avuxoGreen.withAlpha(20)
                  : Colors.black26,
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(
                milliseconds: 250,
              ),
              curve: Curves.easeOutCubic,
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? avuxoGreen
                    : Colors.white24,
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: avuxoGreen
                              .withAlpha(180),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline
                        ? 'ONLINE'
                        : 'OFFLINE',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isOnline
                          ? avuxoGreen
                          : Colors.white54,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isOnline
                        ? 'Recebendo corridas'
                        : 'Você está offline',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Colors.white.withAlpha(155),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Switch(
              value: isOnline,
              onChanged: onChanged,
              activeColor: Colors.black,
              activeTrackColor: avuxoGreen,
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }
}