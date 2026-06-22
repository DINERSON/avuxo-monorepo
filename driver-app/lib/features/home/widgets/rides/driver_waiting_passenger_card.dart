import 'dart:ui';

import 'package:flutter/material.dart';

class DriverWaitingPassengerCard extends StatefulWidget {
  const DriverWaitingPassengerCard({
    super.key,
    required this.passengerName,
    required this.minutesWaiting,
    required this.onCancel,
  });

  final String passengerName;
  final int minutesWaiting;
  final VoidCallback onCancel;

  @override
  State<DriverWaitingPassengerCard> createState() =>
      _DriverWaitingPassengerCardState();
}

class _DriverWaitingPassengerCardState
    extends State<DriverWaitingPassengerCard>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.98,
      upperBound: 1.02,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _safePassengerName {
    final value = widget.passengerName.trim();

    if (value.isEmpty) {
      return 'Passageiro';
    }

    return value;
  }

  int get _safeMinutes {
    if (widget.minutesWaiting < 0) {
      return 0;
    }

    return widget.minutesWaiting;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _controller,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xEB0B1117),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: avuxoGreen.withAlpha(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(26),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avuxoGreen.withAlpha(26),
                      border: Border.all(
                        color: avuxoGreen.withAlpha(61),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avuxoGreen.withAlpha(56),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_rounded,
                      color: avuxoGreen,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'AGUARDANDO\nPASSAGEIRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    _safePassengerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius:
                          BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(13),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_safeMinutes MIN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: avuxoGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 34,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Tempo aguardando',
                          style: TextStyle(
                            color:
                                Colors.white.withAlpha(140),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'CANCELAR CORRIDA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                      ),
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