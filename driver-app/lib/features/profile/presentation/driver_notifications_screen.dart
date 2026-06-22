import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState
    extends State<DriverNotificationsScreen> {
  static const Color avuxoGreen = Color(0xFF24F877);

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://avuxo-backend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  bool _loading = true;
  bool _requestRunning = false;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_requestRunning) return;

    _requestRunning = true;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final phone = await LocalStorage().getPhone();

      if (!mounted) return;

      if (phone == null || phone.trim().isEmpty) {
        setState(() {
          _error = 'Telefone do motorista não encontrado.';
          _loading = false;
        });
        return;
      }

      final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      final profileResponse = await _dio.get(
        '/drivers/status/$normalizedPhone',
      );

      if (!mounted) return;

      final profileData = profileResponse.data;

      if (profileData is! Map ||
          profileData['found'] != true ||
          profileData['driver'] is! Map) {
        setState(() {
          _error = 'Motorista não encontrado.';
          _loading = false;
        });
        return;
      }

      final driverData = Map<String, dynamic>.from(profileData['driver']);
      final driverId = '${driverData['id'] ?? ''}'.trim();

      if (driverId.isEmpty) {
        setState(() {
          _error = 'ID do motorista não veio do backend.';
          _loading = false;
        });
        return;
      }

      final response = await _dio.get(
        '/driver/notifications/$driverId',
      );

      if (!mounted) return;

      final data = response.data;

      if (data is! Map ||
          data['success'] != true ||
          data['notifications'] is! List) {
        setState(() {
          _error = 'Não foi possível carregar as notificações.';
          _loading = false;
        });
        return;
      }

      final rawNotifications = data['notifications'] as List;

      final parsedNotifications = rawNotifications
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);

      setState(() {
        _notifications = parsedNotifications;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro de conexão com o backend.';
        _loading = false;
      });
    } finally {
      _requestRunning = false;
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payments_rounded;
      case 'ride':
        return Icons.local_taxi_rounded;
      case 'goal':
        return Icons.emoji_events_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String _time(dynamic value) {
    final raw = '${value ?? ''}'.trim();

    if (raw.isEmpty) return 'Agora';

    final parsed = DateTime.tryParse(raw);

    if (parsed == null) return raw;

    final local = parsed.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month • $hour:$minute';
  }

  String _text(
    dynamic value, {
    String fallback = '',
  }) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notificações',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading || _requestRunning
                ? null
                : _loadNotifications,
            icon: const Icon(
              Icons.refresh,
              color: avuxoGreen,
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: avuxoGreen,
          strokeWidth: 2.8,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você ainda não possui notificações.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: avuxoGreen,
      backgroundColor: const Color(0xFF141C25),
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];

          return _NotificationCard(
            icon: _icon(_text(item['type'])),
            title: _text(
              item['title'],
              fallback: 'Notificação AVUXO',
            ),
            message: _text(
              item['message'],
              fallback: 'Nova atualização.',
            ),
            time: _time(item['time'] ?? item['createdAt']),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141C25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha(10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: avuxoGreen.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: avuxoGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}