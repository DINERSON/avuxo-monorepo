import 'dart:ui';

import 'package:flutter/material.dart';

class DriverLiveBadge extends StatefulWidget {
  const DriverLiveBadge({
    super.key,
  });

  @override
  State<DriverLiveBadge> createState() =>
      _DriverLiveBadgeState();
}

class _DriverLiveBadgeState
    extends State<DriverLiveBadge>
    with SingleTickerProviderStateMixin {
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
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xEB0B1117),
            borderRadius:
                BorderRadius.circular(999),
            border: Border.all(
              color: Colors.redAccent.withAlpha(56),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent
                    .withAlpha(40),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent
                          .withAlpha(180),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'AO VIVO',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}