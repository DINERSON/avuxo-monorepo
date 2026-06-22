import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverTopStatusBar extends StatelessWidget {
  const DriverTopStatusBar({
    super.key,
    required this.online,
    required this.notifications,
    required this.onNotificationTap,
  });

  final bool online;
  final int notifications;
  final VoidCallback onNotificationTap;

  static const Color avuxoGreen = Color(0xFF24F877);

  int get _safeNotifications {
    if (notifications < 0) {
      return 0;
    }

    return notifications;
  }

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
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online
                    ? avuxoGreen
                    : Colors.white24,
                boxShadow: online
                    ? [
                        BoxShadow(
                          color: avuxoGreen
                              .withAlpha(160),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                online
                    ? 'MOTORISTA ONLINE'
                    :