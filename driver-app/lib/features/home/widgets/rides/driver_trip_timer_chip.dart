import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripTimerChip extends StatefulWidget {
  const DriverTripTimerChip({
    super.key,
    required this.startedAt,
  });

  final DateTime startedAt;

  @override
  State<DriverTripTimerChip> createState() =>
      _DriverTripTimerChipState();
}

class _DriverTripTimerChipState
    extends State<DriverTripTimerChip> {
  static const Color avuxoGreen = Color(0xFF24F877);

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _refreshElapsed();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        _refreshElapsed();
      },
    );
  }

  @override
  void didUpdateWidget(
    covariant DriverTripTimerChip oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startedAt != widget.startedAt) {
      _refreshElapsed();
    }
  }

  void _refreshElapsed() {
    final newElapsed =
        DateTime.now().difference(widget.startedAt);

    if (!mounted) return;

    setState(() {
      _elapsed = newElapsed;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  String _format(Duration duration) {
    final hours =
        duration.inHours.toString().padLeft(2, '0');

    final minutes =
        (duration.inMinutes % 60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (duration.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius:
                  BorderRadius.circular(999),
              border: Border.all(
                color: avuxoGreen.withAlpha(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(26),
                  blurRadius: 18,
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
                    color: avuxoGreen,
                    boxShadow: [
                      BoxShadow(
                        color:
                            avuxoGreen.withAlpha(180),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  _format(_elapsed),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}