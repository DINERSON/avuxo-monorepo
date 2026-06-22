import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumDriverMarker extends StatefulWidget {
  const PremiumDriverMarker({
    super.key,
    required this.online,
  });

  final bool online;

  @override
  State<PremiumDriverMarker> createState() =>
      _PremiumDriverMarkerState();
}

class _PremiumDriverMarkerState
    extends State<PremiumDriverMarker>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.94,
      upperBound: 1.06,
    );

    if (widget.online) {
      controller.repeat(reverse: true);
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(
    covariant PremiumDriverMarker oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.online && !oldWidget.online) {
      controller.repeat(reverse: true);
    }

    if (!widget.online && oldWidget.online) {
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
    final active = widget.online;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: active
            ? controller
            : const AlwaysStoppedAnimation(1),
        child: SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (active)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 24,
                      sigmaY: 24,
                    ),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            avuxoGreen.withOpacity(
                          0.08,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                avuxoGreen.withOpacity(
                              0.30,
                            ),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B1117),
                  border: Border.all(
                    color: active
                        ? avuxoGreen
                        : Colors.white24,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: active
                          ? avuxoGreen.withOpacity(
                              0.22,
                            )
                          : Colors.black38,
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons
                      .directions_car_filled_rounded,
                  color: active
                      ? avuxoGreen
                      : Colors.white38,
                  size: 38,
                ),
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? avuxoGreen
                        : Colors.white24,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: avuxoGreen
                                  .withOpacity(
                                0.70,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}