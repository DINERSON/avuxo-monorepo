import 'dart:ui';

import 'package:flutter/material.dart';

class DriverBottomNavigation extends StatelessWidget {
  const DriverBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.92),
              borderRadius:
                  BorderRadius.circular(32),
              border: Border.all(
                color:
                    avuxoGreen.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      avuxoGreen.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                _item(
                  index: 0,
                  icon: Icons.map_rounded,
                  label: 'Mapa',
                ),
                _item(
                  index: 1,
                  icon: Icons.history_rounded,
                  label: 'Corridas',
                ),
                _item(
                  index: 2,
                  icon:
                      Icons.account_balance_wallet_rounded,
                  label: 'Ganhos',
                ),
                _item(
                  index: 3,
                  icon: Icons.person_rounded,
                  label: 'Conta',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(22),
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding:
                const EdgeInsets.symmetric(
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? avuxoGreen
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(22),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: avuxoGreen
                            .withOpacity(0.20),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? Colors.black
                      : Colors.white54,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.black
                        : Colors.white54,
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 11,
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