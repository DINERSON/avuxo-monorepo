import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() =>
      _DriverSettingsScreenState();
}

class _DriverSettingsScreenState
    extends State<DriverSettingsScreen> {
  static const Color avuxoGreen =
      Color(0xFF24F877);

  static const Color bg =
      Color(0xFF0B1117);

  static const Color card =
      Color(0xFF111A22);

  final LocalStorage storage =
      LocalStorage();

  bool loading = true;

  bool rideSound = true;
  bool vibration = true;
  bool darkMode = true;

  bool _saving = false;

  String navigationDefault =
      'Google Maps';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final savedRideSound =
          await storage.getRideSound();

      final savedVibration =
          await storage.getVibration();

      final savedDarkMode =
          await storage.getDarkMode();

      final savedNavigation =
          await storage.getNavigation();

      if (!mounted) return;

      setState(() {
        rideSound = savedRideSound;
        vibration = savedVibration;
        darkMode = savedDarkMode;
        navigationDefault =
            savedNavigation;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _saveRideSound(
    bool value,
  ) async {
    if (_saving) return;

    _saving = true;

    setState(() {
      rideSound = value;
    });

    await storage.saveRideSound(
      value,
    );

    if (!mounted) return;

    _showMessage(
      value
          ? 'Som de corridas ativado.'
          : 'Som de corridas desativado.',
    );

    _saving = false;
  }

  Future<void> _saveVibration(
    bool value,
  ) async {
    if (_saving) return;

    _saving = true;

    setState(() {
      vibration = value;
    });

    await storage.saveVibration(
      value,
    );

    if (!mounted) return;

    _showMessage(
      value
          ? 'Vibração ativada.'
          : 'Vibração desativada.',
    );

    _saving = false;
  }

  Future<void> _saveDarkMode(
    bool value,
  ) async {
    if (_saving) return;

    _saving = true;

    setState(() {
      darkMode = value;
    });

    await storage.saveDarkMode(
      value,
    );

    if (!mounted) return;

    _showMessage(
      'Preferência salva.',
    );

    _saving = false;
  }
  Future<void> _saveNavigation(
    String value,
  ) async {
    if (_saving) return;

    _saving = true;

    setState(() {
      navigationDefault = value;
    });

    await storage.saveNavigation(value);

    if (!mounted) return;

    _showMessage(
      'Navegação padrão: $value',
    );

    _saving = false;
  }

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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Configurações',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: avuxoGreen,
                strokeWidth: 2.8,
              ),
            )
          : RepaintBoundary(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Preferências do motorista',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: avuxoGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Controle sons, vibração, navegação, privacidade e permissões.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(166),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _switchCard(
                    icon: Icons.volume_up_rounded,
                    title: 'Som de corridas',
                    subtitle: 'Tocar alerta ao receber nova corrida',
                    value: rideSound,
                    onChanged: _saveRideSound,
                  ),
                  _switchCard(
                    icon: Icons.vibration_rounded,
                    title: 'Vibração',
                    subtitle: 'Vibrar quando chegar uma solicitação',
                    value: vibration,
                    onChanged: _saveVibration,
                  ),
                  _navigationCard(),
                  _switchCard(
                    icon: Icons.dark_mode_rounded,
                    title: 'Modo escuro',
                    subtitle: 'Interface premium escura AVUXO',
                    value: darkMode,
                    onChanged: _saveDarkMode,
                  ),
                  _actionCard(
                    icon: Icons.lock_rounded,
                    title: 'Privacidade',
                    subtitle: 'Gerencie segurança e dados da conta',
                    onTap: () {
                      _showMessage(
                        'Privacidade será conectada ao backend.',
                      );
                    },
                  ),
                  _actionCard(
                    icon: Icons.location_on_rounded,
                    title: 'Permissões',
                    subtitle: 'Localização, câmera e notificações',
                    onTap: () {
                      _showMessage(
                        'Permissões do aparelho serão abertas em breve.',
                      );
                    },
                  ),
                  _versionCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _switchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: _textBlock(
              title,
              subtitle,
            ),
          ),
          Switch(
            value: value,
            activeColor: avuxoGreen,
            activeTrackColor: avuxoGreen.withAlpha(90),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white12,
            onChanged: _saving ? null : onChanged,
          ),
        ],
      ),
    );
  }

  Widget _navigationCard() {
    final safeNavigation = navigationDefault == 'Waze'
        ? 'Waze'
        : 'Google Maps';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(Icons.map_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: _textBlock(
              'Navegação padrão',
              'Escolha o app usado para rotas',
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeNavigation,
              dropdownColor: card,
              iconEnabledColor: avuxoGreen,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Google Maps',
                  child: Text('Google Maps'),
                ),
                DropdownMenuItem(
                  value: 'Waze',
                  child: Text('Waze'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value == null) return;
                      _saveNavigation(value);
                    },
            ),
          ),
        ],
      ),
    );
  }
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: _iconBox(icon),
        title: Text(
          _safeText(title, 'Opção'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          _safeText(subtitle, 'Configuração disponível.'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(140),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: avuxoGreen,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _versionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(Icons.phone_android_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: _textBlock(
              'Versão do aplicativo',
              'AVUXO Motorista',
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: avuxoGreen.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: avuxoGreen.withAlpha(90),
              ),
            ),
            child: const Text(
              '1.0.0',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: avuxoGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: avuxoGreen.withAlpha(30),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: avuxoGreen.withAlpha(64),
        ),
      ),
      child: Icon(
        icon,
        color: avuxoGreen,
        size: 24,
      ),
    );
  }

  Widget _textBlock(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _safeText(title, 'Configuração'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _safeText(subtitle, 'Ajuste disponível.'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(140),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: Colors.white.withAlpha(15),
      ),
      boxShadow: [
        BoxShadow(
          color: avuxoGreen.withAlpha(12),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;

    final safeText = _safeText(
      text,
      'Preferência salva.',
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: card,
          behavior: SnackBarBehavior.floating,
          content: Text(
            safeText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }
}