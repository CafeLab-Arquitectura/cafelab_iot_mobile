import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionStorage {
  static const _emailKey = 'session_user_email';
  static const _userIdKey = 'session_user_id';
  static const _profileIdKey = 'session_profile_id';
  static const _planKey = 'session_profile_plan';
  static const _hasPlanKey = 'session_profile_has_plan';

  final TokenStorageService _tokenStorage;

  UserSessionStorage({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim());
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> saveUserId(int userId) async {
    if (userId <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  /// Resolves the authenticated user's ID using multiple fallbacks:
  /// 1. Stored userId key.
  /// 2. Stored profileId key (since profile.id == user profile entity in backend).
  /// 3. Decoded JWT claims ("userId", "id", or numeric "sub").
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt(_userIdKey);
    if (storedUserId != null && storedUserId > 0) {
      return storedUserId;
    }

    final storedProfileId = prefs.getInt(_profileIdKey);
    if (storedProfileId != null && storedProfileId > 0) {
      await prefs.setInt(_userIdKey, storedProfileId);
      return storedProfileId;
    }

    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final parsedId = extractUserIdFromJwt(token);
      if (parsedId != null && parsedId > 0) {
        await prefs.setInt(_userIdKey, parsedId);
        return parsedId;
      }
    }

    return null;
  }

  static int? extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        final raw = data['userId'] ?? data['id'] ?? data['user_id'];
        if (raw is num) return raw.toInt();
        if (raw is String) {
          final parsed = int.tryParse(raw);
          if (parsed != null && parsed > 0) return parsed;
        }
        final sub = data['sub'];
        if (sub is num) return sub.toInt();
        if (sub is String) {
          final parsedSub = int.tryParse(sub);
          if (parsedSub != null && parsedSub > 0) return parsedSub;
        }
      }
    } catch (_) {
      // Ignore token parse errors.
    }
    return null;
  }

  Future<void> saveProfileState({
    required int profileId,
    required String plan,
    required bool hasPlan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileId > 0) {
      await prefs.setInt(_userIdKey, profileId);
    }
    await prefs.setInt(_profileIdKey, profileId);
    await prefs.setString(_planKey, plan);
    await prefs.setBool(_hasPlanKey, hasPlan);
  }

  Future<int?> getProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileIdKey);
  }

  Future<String?> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planKey);
  }

  Future<bool?> getHasPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPlanKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_profileIdKey);
    await prefs.remove(_planKey);
    await prefs.remove(_hasPlanKey);
  }

  Future<void> clearEmail() => clearSession();
}
