import 'dart:ui';

import 'package:flutter/material.dart';

class DriverConnectionStatusCard extends StatelessWidget {
  const DriverConnectionStatusCard({
    super.key,
    required this.connected,
    required this.backendConnected,
    required this.locationActive,
  });

  final bool connected;
  final bool backendConnected;
  final bool locationActive;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: avuxoGreen.withAlpha(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(15),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus({
    required String title,
    required bool value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? avuxoGreen.withAlpha(26)
                : Colors.white12,
            border: Border.all(
              color: value
                  ? avuxoGreen.withAlpha(56)
                  : Colors.white12,
            ),
          ),
          child: Icon(
            icon,
            color: value
                ? avuxoGreen
                : Colors.white38,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value
                    ? 'Conectado'
                    : 'Desconectado',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value
                      ? avuxoGreen
                      : Colors.white54,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOutCubic,
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? avuxoGreen
                : Colors.white24,
            boxShadow: value
                ? [
                    BoxShadow(
                      color:
                          avuxoGreen.withAlpha(180),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: avuxoGreen.withAlpha(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(15),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatus(
                  title: 'Realtime',
                  value: connected,
                  icon:
                      Icons.wifi_tethering_rounded,
                ),

                const SizedBox(height: 16),

                _buildStatus(
                  title: 'Backend',
                  value: backendConnected,
                  icon: Icons.dns_rounded,
                ),

                const SizedBox(height: 16),

                _buildStatus(
                  title: 'GPS',
                  value: locationActive,
                  icon: Icons
                      .location_searching_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}