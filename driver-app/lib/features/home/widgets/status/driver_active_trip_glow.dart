import 'dart:ui';

import 'package:flutter/material.dart';

class DriverActiveTripGlow extends StatefulWidget {
  const DriverActiveTripGlow({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  State<DriverActiveTripGlow> createState() =>
      _DriverActiveTripGlowState();
}

class _DriverActiveTripGlowState
    extends State<DriverActiveTripGlow>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant DriverActiveTripGlow oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.active != widget.active) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.active) {
      if (!_animating) {
        _animating = true;
        _controller.repeat(reverse: true);
      }
    } else {
      if (_animating) {
        _animating = false;
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: Center(
          child: ScaleTransition(
            scale: _controller,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avuxoGreen.withAlpha(16),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(70),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: avuxoGreen.withAlpha(28),
                    blurRadius: 80,
                    spreadRadius: 10,
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