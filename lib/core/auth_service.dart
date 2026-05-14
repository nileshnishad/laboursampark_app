import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyOtpVerified = 'otp_verified';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyRememberedEmail = 'remembered_email';
  static const String _keyRememberedPassword = 'remembered_password';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyUserData);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyOtpVerified);
    // Note: We don't clear remember me credentials on logout, 
    // so user can still use them for next login if they want
  }

  static Future<bool> isOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOtpVerified) ?? false;
  }

  static Future<void> setOtpVerified(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOtpVerified, value);
  }

  // Remember Me functionality
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  static Future<void> saveRememberedCredentials(String emailOrMobile, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRememberedEmail, emailOrMobile);
    await prefs.setString(_keyRememberedPassword, password);
  }

  static Future<Map<String, String?>> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'emailOrMobile': prefs.getString(_keyRememberedEmail),
      'password': prefs.getString(_keyRememberedPassword),
    };
  }

  static Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberedEmail);
    await prefs.remove(_keyRememberedPassword);
  }
}
