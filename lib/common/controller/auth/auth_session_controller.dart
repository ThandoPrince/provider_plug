import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/provider_login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';


import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

class AuthSessionController with ChangeNotifier {
  AuthSessionController._internal();

  static final AuthSessionController instance =
      AuthSessionController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _email;
  int? _id;
  String? _accessToken;
  String? _refreshToken;

  String? get email => _email;
  int? get id => _id;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn =>
      _accessToken?.isNotEmpty == true &&
      _refreshToken?.isNotEmpty == true;

  static const _kEmail = "auth_email";
  static const _kId = "auth_id";
  static const _kAccess = "auth_access_token";
  static const _kRefresh = "auth_refresh_token";

  Future<void> loadSession() async {
    _email = await _storage.read(key: _kEmail);

    final storedId = await _storage.read(key: _kId);
    _id = storedId != null ? int.tryParse(storedId) : null;

    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);

    notifyListeners();
  }

  Future<void> setSession({
    required int id,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    _id = id;
    _email = email;
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await Future.wait([
      _storage.write(key: _kId, value: id.toString()),
      _storage.write(key: _kEmail, value: email),
      _storage.write(key: _kAccess, value: accessToken),
      _storage.write(key: _kRefresh, value: refreshToken),
    ]);

    notifyListeners();
  }

  Future<void> clearSession() async {
    _id = null;
    _email = null;
    _accessToken = null;
    _refreshToken = null;

    await _storage.deleteAll();

    notifyListeners();
  }

  Future<String?> refreshAccessToken() async {
    if (_refreshToken == null) return null;

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/client/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _accessToken = data['access'];

        await _storage.write(
          key: _kAccess,
          value: _accessToken,
        );

        notifyListeners();

        return _accessToken;
      }

      await clearSession();
      return null;
    } catch (_) {
      return null;
    }
  }
}