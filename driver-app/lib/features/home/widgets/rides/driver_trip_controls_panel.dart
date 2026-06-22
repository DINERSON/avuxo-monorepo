import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverTripControlsPanel extends StatelessWidget {
  const DriverTripControlsPanel({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.loading,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool loading;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF00B1117),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: avuxoGreen.withAlpha(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 62,
                    child: ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              onDecline();
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'RECUSAR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        disabledBackgroundColor:
                            Colors.redAccent.withAlpha(120),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 62,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              onAccept();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: avuxoGreen,
                        disabledBackgroundColor:
                            avuxoGreen.withAlpha(120),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'ACEITAR CORRIDA',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight:
                                          FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
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