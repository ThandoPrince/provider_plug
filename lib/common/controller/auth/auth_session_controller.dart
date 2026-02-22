import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionController with ChangeNotifier {
  static final AuthSessionController _instance = AuthSessionController._internal();
  factory AuthSessionController() => _instance;
  static AuthSessionController get instance => _instance;
  AuthSessionController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _email;
  String? get email => _email;
  bool get isLoggedIn => _email != null;

  static const String _emailKey = "logged_in_email";

  /// Load session when app starts
  Future<void> loadSession() async {
    _email = await _storage.read(key: _emailKey);
    notifyListeners();
  }

  /// Save session securely
  Future<void> setSession(String email) async {
    _email = email;
    await _storage.write(key: _emailKey, value: email);
    notifyListeners();
  }

  /// Logout
  Future<void> clearSession() async {
    _email = null;
    await _storage.delete(key: _emailKey);
    notifyListeners();
  }
}
