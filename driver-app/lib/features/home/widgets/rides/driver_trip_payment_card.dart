import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripPaymentCard extends StatelessWidget {
  const DriverTripPaymentCard({
    super.key,
    required this.price,
    required this.paymentMethod,
    required this.surge,
  });

  final String price;
  final String paymentMethod;
  final bool surge;

  static const Color avuxoGreen = Color(0xFF24F877);

  String _safeText(
    String value,
    String fallback,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final safePrice = _safeText(
      price,
      'R\$ 0,00',
    );

    final safePaymentMethod = _safeText(
      paymentMethod,
      'Forma de pagamento não informada',
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xEB0B1117),
              borderRadius: BorderRadius.circular(32),
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
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(26),
                    border: Border.all(
                      color: avuxoGreen.withAlpha(61),
                    ),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: avuxoGreen,
                    size: 36,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        safePrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        safePaymentMethod,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(155),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                if (surge) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent
                                .withAlpha(61),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.black,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'DINÂMICA',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}