import 'package:flutter/material.dart';

class IncomingRideSoundOverlay extends StatefulWidget {
  const IncomingRideSoundOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  State<IncomingRideSoundOverlay> createState() =>
      _IncomingRideSoundOverlayState();
}

class _IncomingRideSoundOverlayState
    extends State<IncomingRideSoundOverlay>
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
        milliseconds: 1200,
      ),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant IncomingRideSoundOverlay oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.visible) {
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
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Container(
            color: Colors.black.withAlpha(30),
            child: Center(
              child: ScaleTransition(
                scale: _controller,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(20),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(80),
                        blurRadius: 35,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: avuxoGreen.withAlpha(35),
                        blurRadius: 60,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xEB0B1117),
                        border: Border.all(
                          color: avuxoGreen.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avuxoGreen.withAlpha(40),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: avuxoGreen,
                        size: 50,
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