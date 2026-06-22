import 'dart:ui';

import 'package:flutter/material.dart';

class DriverCancelDialog extends StatelessWidget {
  const DriverCancelDialog({
    super.key,
    required this.onConfirm,
    required this.onClose,
    this.message,
  });

  final VoidCallback onConfirm;
  final VoidCallback onClose;
  final String? message;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safeMessage {
    final text = message?.trim() ?? '';

    if (text.isEmpty || text == 'null') {
      return 'Tem certeza que deseja cancelar esta corrida da AVUXO?';
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1117)
                    .withOpacity(0.96),
                borderRadius:
                    BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.redAccent
                      .withOpacity(0.20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent
                        .withOpacity(0.10),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent
                          .withOpacity(0.10),
                      border: Border.all(
                        color: Colors.redAccent
                            .withOpacity(0.24),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.redAccent,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'CANCELAR\nCORRIDA?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _safeMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(0.62),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white10,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),
                              ),
                            ),
                            child: const Text(
                              'VOLTAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: onConfirm,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),
                              ),
                            ),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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