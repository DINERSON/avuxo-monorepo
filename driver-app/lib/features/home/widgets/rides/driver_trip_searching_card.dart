import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripSearchingCard extends StatefulWidget {
  const DriverTripSearchingCard({
    super.key,
    required this.online,
  });

  final bool online;

  @override
  State<DriverTripSearchingCard> createState() =>
      _DriverTripSearchingCardState();
}

class _DriverTripSearchingCardState
    extends State<DriverTripSearchingCard>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant DriverTripSearchingCard oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.online != widget.online) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.online) {
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
    return RepaintBoundary(
      child: ScaleTransition(
        scale: widget.online
            ? _controller
            : const AlwaysStoppedAnimation(1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF00B1117),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: widget.online
                      ? avuxoGreen.withAlpha(46)
                      : Colors.white12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.online
                        ? avuxoGreen.withAlpha(26)
                        : Colors.black26,
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avuxoGreen.withAlpha(26),
                      border: Border.all(
                        color: avuxoGreen.withAlpha(61),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avuxoGreen.withAlpha(56),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      color: avuxoGreen,
                      size: 56,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    widget.online
                        ? 'PROCURANDO\nCORRIDAS'
                        : 'MODO\nOFFLINE',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      height: 1.08,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    widget.online
                        ? 'A plataforma AVUXO está buscando passageiros próximos em tempo real.'
                        : 'Ative o modo online para começar a receber viagens.',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(158),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(999),
                    child: widget.online
                        ? const LinearProgressIndicator(
                            minHeight: 8,
                            backgroundColor:
                                Colors.white12,
                            color: avuxoGreen,
                          )
                        : Container(
                            height: 8,
                            width: double.infinity,
                            color: Colors.white12,
                          ),
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