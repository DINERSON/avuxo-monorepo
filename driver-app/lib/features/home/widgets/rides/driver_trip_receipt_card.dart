import 'dart:ui';

import 'package:flutter/material.dart';

class DriverTripReceiptCard extends StatelessWidget {
  const DriverTripReceiptCard({
    super.key,
    required this.passengerName,
    required this.total,
    required this.avuxoFee,
    required this.driverAmount,
    required this.distance,
    required this.duration,
    required this.paymentMethod,
  });

  final String passengerName;
  final String total;
  final String avuxoFee;
  final String driverAmount;
  final String distance;
  final String duration;
  final String paymentMethod;

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
    final safePassengerName =
        _safeText(passengerName, 'Passageiro');

    final safeTotal =
        _safeText(total, 'R\$ 0,00');

    final safeAvuxoFee =
        _safeText(avuxoFee, 'R\$ 0,00');

    final safeDriverAmount =
        _safeText(driverAmount, 'R\$ 0,00');

    final safeDistance =
        _safeText(distance, '-- km');

    final safeDuration =
        _safeText(duration, '-- min');

    final safePaymentMethod =
        _safeText(
      paymentMethod,
      'Não informado',
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                        color: avuxoGreen.withAlpha(46),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: avuxoGreen,
                    size: 46,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'RECIBO\nDA CORRIDA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                    height: 1.08,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  safePassengerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(175),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 26),

                _line(
                  title: 'Valor total',
                  value: safeTotal,
                  highlight: true,
                ),

                _divider(),

                _line(
                  title: 'Taxa AVUXO (20%)',
                  value: safeAvuxoFee,
                ),

                _divider(),

                _line(
                  title: 'Você recebeu',
                  value: safeDriverAmount,
                  highlight: true,
                ),

                _divider(),

                _line(
                  title: 'Distância',
                  value: safeDistance,
                ),

                _divider(),

                _line(
                  title: 'Duração',
                  value: safeDuration,
                ),

                _divider(),

                _line(
                  title: 'Pagamento',
                  value: safePaymentMethod,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      height: 1,
      color: Colors.white.withAlpha(12),
    );
  }

  Widget _line({
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlight
                  ? avuxoGreen
                  : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: highlight ? 20 : 15,
            ),
          ),
        ),
      ],
    );
  }
}