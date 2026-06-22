import 'dart:ui';

import 'package:flutter/material.dart';

class RideProgressTimeline extends StatelessWidget {
  const RideProgressTimeline({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const Color avuxoGreen = Color(0xFF24F877);

  static const List<String> _steps = [
    'Aceita',
    'Cheguei',
    'Viagem',
    'Fim',
  ];

  @override
  Widget build(BuildContext context) {
    final safeCurrentStep = currentStep.clamp(
      0,
      _steps.length - 1,
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xE60B1117),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: avuxoGreen.withAlpha(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _steps.length,
                (index) {
                  final active =
                      index <= safeCurrentStep;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds: 250,
                                ),
                                curve:
                                    Curves.easeOutCubic,
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  color: active
                                      ? avuxoGreen
                                      : Colors.white12,
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color:
                                                avuxoGreen
                                                    .withAlpha(
                                              76,
                                            ),
                                            blurRadius:
                                                12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: active
                                      ? Colors.black
                                      : Colors.white38,
                                  size: 19,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                _steps[index],
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (index !=
                            _steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 3,
                              margin:
                                  const EdgeInsets.only(
                                bottom: 22,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: active
                                    ? avuxoGreen
                                    : Colors.white12,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  999,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}