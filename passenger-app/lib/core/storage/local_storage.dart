import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/user_profile.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';

  Future<void> saveAuth(
    String token,
    UserProfile user,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userKey,
      jsonEncode({
        'id': user.id,
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'email': user.email,
      }),
    );
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(_tokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token;
  }

  Future<UserProfile?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_userKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return UserProfile.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}