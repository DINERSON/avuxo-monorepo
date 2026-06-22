import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RideRequestCard extends StatelessWidget {
  const RideRequestCard({
    super.key,
    required this.passengerName,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.distance,
    required this.eta,
    required this.onAccept,
    required this.onDecline,
  });

  final String passengerName;
  final String pickup;
  final String destination;
  final double price;
  final String distance;
  final String eta;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

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

  String _formatPrice() {
    final safePrice = price.isFinite && price >= 0
        ? price
        : 0.0;

    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(safePrice);
  }

  @override
  Widget build(BuildContext context) {
    final money = _formatPrice();

    final safePassengerName = _safeText(
      passengerName,
      'Passageiro',
    );

    final safePickup = _safeText(
      pickup,
      'Local de embarque não informado',
    );

    final safeDestination = _safeText(
      destination,
      'Destino não informado',
    );

    final safeDistance = _safeText(
      distance,
      '-- km',
    );

    final safeEta = _safeText(
      eta,
      '-- min',
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
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF00B1117),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: avuxoGreen.withAlpha(38),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(22),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avuxoGreen.withAlpha(26),
                        border: Border.all(
                          color: avuxoGreen.withAlpha(61),
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: avuxoGreen,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NOVA CORRIDA',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: avuxoGreen,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            safePassengerName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Flexible(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: avuxoGreen,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Text(
                          money,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight:
                                FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _locationTile(
                  icon:
                      Icons.radio_button_checked,
                  iconColor: avuxoGreen,
                  title: 'EMBARQUE',
                  value: safePickup,
                ),

                const SizedBox(height: 16),

                _locationTile(
                  icon: Icons.location_on,
                  iconColor: Colors.redAccent,
                  title: 'DESTINO',
                  value: safeDestination,
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        icon: Icons.route,
                        title: 'Distância',
                        value: safeDistance,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoBox(
                        icon:
                            Icons.access_time_filled,
                        title: 'Tempo',
                        value: safeEta,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 72,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback
                                .mediumImpact();
                            onDecline();
                          },
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: const Text(
                            'RECUSAR',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
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
                                22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 72,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback
                                .mediumImpact();
                            onAccept();
                          },
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 28,
                          ),
                          label: const Text(
                            'ACEITAR',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                avuxoGreen,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),
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

  Widget _locationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withAlpha(26),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      Colors.white.withAlpha(115),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withAlpha(13),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: avuxoGreen,
            size: 22,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(115),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}