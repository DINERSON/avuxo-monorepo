import 'dart:ui';

import 'package:flutter/material.dart';

class DriverGlassCard extends StatelessWidget {
  const DriverGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 30,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? color;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: color ??
                      const Color(0xFF0B1117)
                          .withOpacity(0.90),
                  borderRadius:
                      BorderRadius.circular(
                    borderRadius,
                  ),
                  border: Border.all(
                    color:
                        avuxoGreen.withOpacity(0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: avuxoGreen
                          .withOpacity(0.05),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}