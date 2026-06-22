import 'package:flutter/material.dart';

class OnlineGlowIndicator extends StatefulWidget {
  const OnlineGlowIndicator({
    super.key,
    required this.isOnline,
  });

  final bool isOnline;

  @override
  State<OnlineGlowIndicator> createState() =>
      _OnlineGlowIndicatorState();
}

class _OnlineGlowIndicatorState
    extends State<OnlineGlowIndicator>
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
        milliseconds: 1600,
      ),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant OnlineGlowIndicator oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isOnline != widget.isOnline) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isOnline) {
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
    if (!widget.isOnline) {
      return const RepaintBoundary(
        child: SizedBox(
          width: 18,
          height: 18,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avuxoGreen,
            boxShadow: [
              BoxShadow(
                color: avuxoGreen.withAlpha(160),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}