import 'dart:ui';

import 'package:flutter/material.dart';

class DriverBottomGlassPanel extends StatelessWidget {
  const DriverBottomGlassPanel({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.showHandle = true,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showHandle;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(38),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            width: double.infinity,
            height: height,
            padding: padding ??
                const EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  26,
                ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.95),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(38),
              ),
              border: Border.all(
                color: avuxoGreen.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      avuxoGreen.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHandle) ...[
                  Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(999),
                      color: Colors.white12,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}