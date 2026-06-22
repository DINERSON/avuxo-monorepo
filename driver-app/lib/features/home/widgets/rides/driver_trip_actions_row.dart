import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverTripActionsRow extends StatelessWidget {
  const DriverTripActionsRow({
    super.key,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
  });

  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.call_rounded,
              label: 'Ligar',
              color: avuxoGreen,
              onTap: onCall,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _ActionButton(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              color: Colors.blueAccent,
              onTap: onChat,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _ActionButton(
              icon: Icons.close_rounded,
              label: 'Cancelar',
              color: Colors.redAccent,
              onTap: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xEB0B1117),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withAlpha(46),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(20),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
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