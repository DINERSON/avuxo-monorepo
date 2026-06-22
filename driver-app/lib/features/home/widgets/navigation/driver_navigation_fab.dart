import 'dart:ui';

import 'package:flutter/material.dart';

class DriverNavigationFab extends StatelessWidget {
  const DriverNavigationFab({
    super.key,
    required this.onTap,
    required this.active,
  });

  final VoidCallback onTap;
  final bool active;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(999),
              onTap: onTap,
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? avuxoGreen
                      : const Color(0xFF0B1117)
                          .withOpacity(0.92),
                  border: Border.all(
                    color: active
                        ? avuxoGreen
                        : Colors.white10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: active
                          ? avuxoGreen
                              .withOpacity(0.22)
                          : Colors.black26,
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.navigation_rounded,
                  color: active
                      ? Colors.black
                      : Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}