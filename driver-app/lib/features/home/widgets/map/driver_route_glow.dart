import 'dart:ui';

import 'package:flutter/material.dart';

class DriverRouteGlow extends StatefulWidget {
  const DriverRouteGlow({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  State<DriverRouteGlow> createState() =>
      _DriverRouteGlowState();
}

class _DriverRouteGlowState
    extends State<DriverRouteGlow>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.94,
      upperBound: 1.08,
    );

    if (widget.visible) {
      controller.repeat(reverse: true);
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(
    covariant DriverRouteGlow oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible && !oldWidget.visible) {
      controller.repeat(reverse: true);
    }

    if (!widget.visible && oldWidget.visible) {
      controller.stop();
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: Center(
          child: ScaleTransition(
            scale: controller,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 60,
                  sigmaY: 60,
                ),
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        avuxoGreen.withOpacity(
                      0.04,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            avuxoGreen.withOpacity(
                          0.20,
                        ),
                        blurRadius: 70,
                        spreadRadius: 12,
                      ),
                      BoxShadow(
                        color:
                            avuxoGreen.withOpacity(
                          0.10,
                        ),
                        blurRadius: 110,
                        spreadRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}