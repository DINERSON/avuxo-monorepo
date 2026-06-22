import 'dart:ui';

import 'package:flutter/material.dart';

class DriverDrawer extends StatelessWidget {
  const DriverDrawer({
    super.key,
    required this.driverName,
    required this.driverPhone,
    required this.onLogout,
    this.onWallet,
    this.onHistory,
    this.onRatings,
    this.onVehicle,
    this.onDocuments,
    this.onSupport,
    this.onSettings,
  });

  final String driverName;
  final String driverPhone;
  final VoidCallback onLogout;

  final VoidCallback? onWallet;
  final VoidCallback? onHistory;
  final VoidCallback? onRatings;
  final VoidCallback? onVehicle;
  final VoidCallback? onDocuments;
  final VoidCallback? onSupport;
  final VoidCallback? onSettings;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get safeDriverName {
    final value = driverName.trim();

    if (value.isEmpty || value == 'null') {
      return 'Motorista AVUXO';
    }

    return value;
  }

  String get safeDriverPhone {
    final value = driverPhone.trim();

    if (value.isEmpty || value == 'null') {
      return 'Telefone não informado';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              color: const Color(0xFF0B1117)
                  .withOpacity(0.94),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            avuxoGreen.withOpacity(
                          0.10,
                        ),
                        border: Border.all(
                          color: avuxoGreen
                              .withOpacity(0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                avuxoGreen.withOpacity(
                              0.12,
                            ),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: avuxoGreen,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        safeDriverName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      safeDriverPhone,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.55),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Expanded(
                      child: ListView(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        children: [
                          _tile(
                            icon: Icons
                                .account_balance_wallet_rounded,
                            title: 'Ganhos',
                            onTap: onWallet,
                          ),
                          _tile(
                            icon:
                                Icons.history_rounded,
                            title: 'Histórico',
                            onTap: onHistory,
                          ),
                          _tile(
                            icon: Icons.star_rounded,
                            title: 'Avaliações',
                            onTap: onRatings,
                          ),
                          _tile(
                            icon: Icons
                                .car_rental_rounded,
                            title: 'Veículo',
                            onTap: onVehicle,
                          ),
                          _tile(
                            icon:
                                Icons.badge_rounded,
                            title: 'Documentos',
                            onTap: onDocuments,
                          ),
                          _tile(
                            icon: Icons
                                .support_agent_rounded,
                            title: 'Suporte',
                            onTap: onSupport,
                          ),
                          _tile(
                            icon: Icons
                                .settings_rounded,
                            title: 'Configurações',
                            onTap: onSettings,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: onLogout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'SAIR',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 14,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: avuxoGreen,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white24,
          size: 16,
        ),
      ),
    );
  }
}