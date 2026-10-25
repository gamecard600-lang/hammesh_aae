import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class OnlineAuthService {
  static const _tokenKey = 'firebase_id_token_v1';
  static const _refreshKey = 'firebase_refresh_token_v1';
  static const _uidKey = 'firebase_uid_v1';
  static const _expiryKey = 'firebase_token_expiry_v1';
  static DateTime? _expiry;

  static Future<String?> getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_expiryKey);
    if (_expiry == null && expiry != null) _expiry = DateTime.fromMillisecondsSinceEpoch(expiry);
    final cached = prefs.getString(_tokenKey);
    if (cached != null && cached.isNotEmpty && _expiry != null && DateTime.now().isBefore(_expiry!)) return cached;
    if (AppConfig.firebaseWebApiKey.isEmpty) return null;
    final refresh = prefs.getString(_refreshKey);
    if (refresh != null && refresh.isNotEmpty) {
      final token = await _refreshToken(refresh);
      if (token != null) return token;
    }
    return _anonymousSignIn();
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  static Future<String?> _anonymousSignIn() async {
    try {
      final r = await http.post(Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${AppConfig.firebaseWebApiKey}'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'returnSecureToken': true})).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      return await _store(jsonDecode(r.body));
    } catch (e) { debugPrint('Firebase auth failed: $e'); return null; }
  }

  static Future<String?> _refreshToken(String refresh) async {
    try {
      final r = await http.post(Uri.parse('https://securetoken.googleapis.com/v1/token?key=${AppConfig.firebaseWebApiKey}'), headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: 'grant_type=refresh_token&refresh_token=${Uri.encodeQueryComponent(refresh)}').timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      return await _store(jsonDecode(r.body));
    } catch (e) { debugPrint('Firebase token refresh failed: $e'); return null; }
  }

  static Future<String?> _store(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = (data['idToken'] ?? data['id_token'])?.toString();
    if (token == null || token.isEmpty) return null;
    final refresh = (data['refreshToken'] ?? data['refresh_token'])?.toString();
    final uid = (data['localId'] ?? data['user_id'])?.toString();
    final seconds = int.tryParse('${data['expiresIn'] ?? data['expires_in'] ?? 3600}') ?? 3600;
    final safe = seconds < 60 ? 60 : (seconds > 3600 ? 3600 : seconds);
    _expiry = DateTime.now().add(Duration(seconds: safe - 60));
    await prefs.setString(_tokenKey, token);
    if (refresh != null) await prefs.setString(_refreshKey, refresh);
    if (uid != null) await prefs.setString(_uidKey, uid);
    await prefs.setInt(_expiryKey, _expiry!.millisecondsSinceEpoch);
    return token;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_tokenKey, _refreshKey, _uidKey, _expiryKey]) { await prefs.remove(key); }
    _expiry = null;
  }
}
