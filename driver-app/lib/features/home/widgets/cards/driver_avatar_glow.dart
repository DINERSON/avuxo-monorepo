import 'dart:ui';

import 'package:flutter/material.dart';

class DriverAvatarGlow extends StatefulWidget {
  const DriverAvatarGlow({
    super.key,
    required this.size,
    required this.online,
    this.child,
  });

  final double size;
  final bool online;
  final Widget? child;

  @override
  State<DriverAvatarGlow> createState() =>
      _DriverAvatarGlowState();
}

class _DriverAvatarGlowState
    extends State<DriverAvatarGlow>
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
      upperBound: 1.08,
    );

    if (widget.online) {
      controller.repeat(reverse: true);
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(
    covariant DriverAvatarGlow oldWidget,
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
    return ScaleTransition(
      scale: widget.online
          ? controller
          : const AlwaysStoppedAnimation(1),
      child: SizedBox(
        width: widget.size + 34,
        height: widget.size + 34,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.online)
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 28,
                    sigmaY: 28,
                  ),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avuxoGreen.withOpacity(0.10),
                      boxShadow: [
                        BoxShadow(
                          color: avuxoGreen.withOpacity(0.45),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0B1117),
                border: Border.all(
                  color: widget.online
                      ? avuxoGreen
                      : Colors.white24,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.online
                        ? avuxoGreen.withOpacity(0.25)
                        : Colors.black38,
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: widget.child ??
                  Icon(
                    Icons.person,
                    color: widget.online
                        ? avuxoGreen
                        : Colors.white38,
                    size: widget.size * 0.42,
                  ),
            ),
            Positioned(
              bottom: 6,
              right: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.online
                      ? avuxoGreen
                      : Colors.white24,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  boxShadow: widget.online
                      ? [
                          BoxShadow(
                            color:
                                avuxoGreen.withOpacity(0.80),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}