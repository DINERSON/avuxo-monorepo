import 'dart:ui';

import 'package:flutter/material.dart';

class RideSearchingOverlay extends StatefulWidget {
  const RideSearchingOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  State<RideSearchingOverlay> createState() =>
      _RideSearchingOverlayState();
}

class _RideSearchingOverlayState
    extends State<RideSearchingOverlay>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.96,
      upperBound: 1.04,
    );

    if (widget.visible) {
      controller.repeat(reverse: true);
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(
    covariant RideSearchingOverlay oldWidget,
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

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Container(
            color: Colors.black.withOpacity(0.16),
            child: Center(
              child: ScaleTransition(
                scale: controller,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 50,
                      sigmaY: 50,
                    ),
                    child: Container(
                      width: 240,
                      height: 240,
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
                              0.25,
                            ),
                            blurRadius: 60,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color:
                                avuxoGreen.withOpacity(
                              0.12,
                            ),
                            blurRadius: 90,
                            spreadRadius: 18,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(
                              0xFF0B1117,
                            ).withOpacity(0.92),
                            border: Border.all(
                              color:
                                  avuxoGreen.withOpacity(
                                0.22,
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: avuxoGreen,
                                size: 38,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'AVUXO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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