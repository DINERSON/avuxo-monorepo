import 'dart:ui';

import 'package:flutter/material.dart';

class SearchingRidesCard extends StatefulWidget {
  const SearchingRidesCard({
    super.key,
  });

  @override
  State<SearchingRidesCard> createState() =>
      _SearchingRidesCardState();
}

class _SearchingRidesCardState
    extends State<SearchingRidesCard>
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
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: avuxoGreen.withAlpha(38),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(20),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _controller,
                  child: Container(
                    width: 92,
                    height: 92,
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
                      Icons.search_rounded,
                      color: avuxoGreen,
                      size: 44,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'PROCURANDO\nCORRIDAS',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Aguarde enquanto a plataforma AVUXO localiza passageiros próximos.',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 26),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    minHeight: 7,
                    backgroundColor:
                        Colors.white12,
                    color: avuxoGreen,
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