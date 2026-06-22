import 'package:flutter/material.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../auth/presentation/auth_gate.dart';
import '../../../profile/presentation/driver_notifications_screen.dart';
import '../../../profile/presentation/driver_profile_screen.dart';
import '../../../profile/presentation/driver_settings_screen.dart';
import '../../../profile/presentation/driver_support_screen.dart';
import '../../../profile/presentation/driver_trip_history_screen.dart';
import '../../../profile/presentation/driver_vehicle_screen.dart';
import '../../../profile/presentation/driver_wallet_screen.dart';

class DriverSideMenu extends StatelessWidget {
  const DriverSideMenu({super.key});

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF070A0E),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1117),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVUXO',
                    style: TextStyle(
                      color: avuxoGreen,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Motorista Premium',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  top: 18,
                ),
                children: [
                  _item(
                    context,
                    icon: Icons.person_rounded,
                    title: 'Perfil',
                    page:
                        const DriverProfileScreen(),
                  ),
                  _item(
                    context,
                    icon: Icons
                        .account_balance_wallet_rounded,
                    title: 'Carteira',
                    page:
                        const DriverWalletScreen(),
                  ),
                  _item(
                    context,
                    icon: Icons.history_rounded,
                    title:
                        'Histórico de Corridas',
                    page:
                        const DriverTripHistoryScreen(),
                  ),
                  _item(
                    context,
                    icon:
                        Icons.directions_car_rounded,
                    title: 'Meu Veículo',
                    page:
                        const DriverVehicleScreen(),
                  ),
                  _item(
                    context,
                    icon:
                        Icons.notifications_rounded,
                    title: 'Notificações',
                    page:
                        const DriverNotificationsScreen(),
                  ),
                  _item(
                    context,
                    icon:
                        Icons.support_agent_rounded,
                    title: 'Ajuda',
                    page:
                        const DriverSupportScreen(),
                  ),
                  _item(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'Configurações',
                    page:
                        const DriverSettingsScreen(),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Divider(
                      color: Colors.white24,
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () =>
                        _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _logout(
    BuildContext context,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF0B1117),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Sair da conta?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Você deseja encerrar sua sessão AVUXO Motorista?',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await LocalStorage().logoutOnly();

    if (!context.mounted) return;

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
      (_) => false,
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: avuxoGreen,
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight:
              FontWeight.w800,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white24,
        size: 16,
      ),
      onTap: () {
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}