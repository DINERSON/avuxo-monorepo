import 'dart:ui';

import 'package:flutter/material.dart';

class DriverConfirmActionSheet extends StatelessWidget {
  const DriverConfirmActionSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    required this.onCancel,
    this.icon = Icons.flash_on_rounded,
    this.confirmColor = avuxoGreen,
  });

  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final IconData icon;
  final Color confirmColor;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeTitle {
    final value = title.trim();

    if (value.isEmpty || value == 'null') {
      return 'Confirmar ação';
    }

    return value;
  }

  String get safeMessage {
    final value = message.trim();

    if (value.isEmpty || value == 'null') {
      return 'Deseja continuar?';
    }

    return value;
  }

  String get safeConfirmText {
    final value = confirmText.trim();

    if (value.isEmpty || value == 'null') {
      return 'CONFIRMAR';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(38),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              34,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.96),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(38),
              ),
              border: Border.all(
                color:
                    avuxoGreen.withOpacity(0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      avuxoGreen.withOpacity(0.06),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(999),
                    color: Colors.white12,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        confirmColor.withOpacity(
                      0.10,
                    ),
                    border: Border.all(
                      color:
                          confirmColor.withOpacity(
                        0.24,
                      ),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: confirmColor,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  safeTitle,
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
                  safeMessage,
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
                          onPressed: onCancel,
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
                                confirmColor,
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
                          child: Text(
                            safeConfirmText,
                            textAlign:
                                TextAlign.center,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
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
    );
  }
}