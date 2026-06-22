import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripCompleteBanner extends StatefulWidget {
  const DriverTripCompleteBanner({
    super.key,
    required this.visible,
    required this.amount,
  });

  final bool visible;
  final String amount;

  @override
  State<DriverTripCompleteBanner> createState() =>
      _DriverTripCompleteBannerState();
}

class _DriverTripCompleteBannerState
    extends State<DriverTripCompleteBanner>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant DriverTripCompleteBanner oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.visible) {
      if (!_isAnimating) {
        _isAnimating = true;
        _controller.repeat(reverse: true);
      }
    } else {
      if (_isAnimating) {
        _isAnimating = false;
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

  String get _safeAmount {
    final value = widget.amount.trim();

    if (value.isEmpty) {
      return 'R\$ 0,00';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _controller,
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
                  color: avuxoGreen.withAlpha(56),
                ),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(28),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avuxoGreen.withAlpha(26),
                      border: Border.all(
                        color: avuxoGreen.withAlpha(61),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avuxoGreen.withAlpha(46),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: avuxoGreen,
                      size: 44,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CORRIDA FINALIZADA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Valor recebido: $_safeAmount',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: avuxoGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A AVUXO registrou a viagem com sucesso.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(155),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
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