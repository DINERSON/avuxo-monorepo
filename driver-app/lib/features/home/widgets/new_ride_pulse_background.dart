import 'package:flutter/material.dart';

class NewRidePulseBackground extends StatefulWidget {
  const NewRidePulseBackground({
    super.key,
  });

  @override
  State<NewRidePulseBackground> createState() =>
      _NewRidePulseBackgroundState();
}

class _NewRidePulseBackgroundState
    extends State<NewRidePulseBackground>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

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
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                color: avuxoGreen.withAlpha(18),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(70),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: avuxoGreen.withAlpha(30),
                    blurRadius: 60,
                    spreadRadius: 8,
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