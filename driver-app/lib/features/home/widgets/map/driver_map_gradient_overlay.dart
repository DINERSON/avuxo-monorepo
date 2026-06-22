import 'package:flutter/material.dart';

class DriverMapGradientOverlay extends StatelessWidget {
  const DriverMapGradientOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(0, 0, 0, 0.78),
                Color.fromRGBO(0, 0, 0, 0.18),
                Color.fromRGBO(0, 0, 0, 0.10),
                Color.fromRGBO(0, 0, 0, 0.82),
              ],
              stops: [
                0.0,
                0.25,
                0.55,
                1.0,
              ],
            ),
          ),
        ),
      ),
    );
  }
}