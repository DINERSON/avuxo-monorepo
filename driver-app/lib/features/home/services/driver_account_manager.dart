import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/storage/local_storage.dart';

class DriverAccountManager {
  DriverAccountManager({
    required this.dio,
    required this.storage,
  });

  final Dio dio;
  final LocalStorage storage;

  Timer? _blockCheckTimer;
  bool _alreadyBlocked = false;

  String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<Map<String, dynamic>> loadDriverProfile() async {
    try {
      final phone = await storage.getPhone();

      if (phone == null || phone.trim().isEmpty) {
        return {};
      }

      final normalizedPhone = normalizePhone(phone);

      if (normalizedPhone.isEmpty) {
        return {};
      }

      final response = await dio.get('/drivers/status/$normalizedPhone');
      final data = response.data;

      if (data is! Map) return {};

      final driver = data['driver'] ?? data['data'] ?? data;

      if (driver is Map) {
        return Map<String, dynamic>.from(driver);
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  void startBlockCheck({
    required void Function(String reason) onBlocked,
  }) {
    stopBlockCheck();

    _blockCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkDriverBlocked(onBlocked: onBlocked),
    );

    checkDriverBlocked(onBlocked: onBlocked);
  }

  void stopBlockCheck() {
    _blockCheckTimer?.cancel();
    _blockCheckTimer = null;
  }

  Future<void> checkDriverBlocked({
    required void Function(String reason) onBlocked,
  }) async {
    try {
      final phone = await storage.getPhone();

      if (phone == null || phone.trim().isEmpty) return;

      final normalizedPhone = normalizePhone(phone);

      if (normalizedPhone.isEmpty) return;

      final response = await dio.get('/drivers/status/$normalizedPhone');
      final data = response.data;

      if (data is! Map) return;

      final blocked = data['blocked'] == true || data['status'] == 'blocked';

      if (!blocked) {
        _alreadyBlocked = false;
        return;
      }

      if (_alreadyBlocked) {
        return;
      }

      _alreadyBlocked = true;

      final reason = '${data['blockedReason'] ?? ''}'.trim();

      await storage.saveBlockedStatus(
        blocked: true,
        reason: reason,
      );

      await storage.clearSession();

      onBlocked(reason);
    } catch (_) {}
  }

  void dispose() {
    stopBlockCheck();
  }
}