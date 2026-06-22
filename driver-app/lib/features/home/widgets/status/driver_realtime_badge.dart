import 'package:flutter/material.dart';

class DriverRealtimeBadge extends StatefulWidget {
  const DriverRealtimeBadge({
    super.key,
    required this.connected,
  });

  final bool connected;

  @override
  State<DriverRealtimeBadge> createState() =>
      _DriverRealtimeBadgeState();
}

class _DriverRealtimeBadgeState
    extends State<DriverRealtimeBadge>
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
    covariant DriverRealtimeBadge oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.connected != widget.connected) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.connected) {
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
    final active = widget.connected;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: active
            ? _controller
            : const AlwaysStoppedAnimation(1.0),
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
              color: active
                  ? avuxoGreen.withAlpha(56)
                  : Colors.white12,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color:
                          avuxoGreen.withAlpha(40),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 250,
                ),
                curve: Curves.easeOutCubic,
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? avuxoGreen
                      : Colors.white24,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: avuxoGreen
                                .withAlpha(180),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                active
                    ? 'REALTIME ONLINE'
                    : 'REALTIME OFFLINE',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: active
                      ? avuxoGreen
                      : Colors.white54,
                  fontWeight:
                      FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}