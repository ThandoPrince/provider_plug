import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';


import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

class AuthSessionController with ChangeNotifier {
  AuthSessionController._internal();

  static final AuthSessionController instance =
      AuthSessionController._internal();
Future<String?>? _refreshFuture;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kIsLoggedIn = "auth_is_logged_in";


  int? _id;
  String? _accessToken;
  String? _refreshToken;

  bool _isLoggedIn = false;
bool get isLoggedIn => _isLoggedIn;


  int? get id => _id;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;



  bool _loggedOut = false;
  bool get loggedOut => _loggedOut;



  static const _kId = "auth_id";
  static const _kAccess = "auth_access_token";
  static const _kRefresh = "auth_refresh_token";

  Future<void> loadSession() async {
  final storedId = await _storage.read(key: _kId);

  _id = storedId != null
      ? int.tryParse(storedId)
      : null;

  _accessToken = await _storage.read(key: _kAccess);
  _refreshToken = await _storage.read(key: _kRefresh);

  final storedLoggedIn =
      await _storage.read(key: _kIsLoggedIn);

  _isLoggedIn = storedLoggedIn == 'true';
  _loggedOut = !_isLoggedIn;

  notifyListeners();
}

 Future<void> setLoggedIn(bool value) async {
  _isLoggedIn = value;
  _loggedOut = !value;

  await _storage.write(
    key: _kIsLoggedIn,
    value: value.toString(),
  );

  notifyListeners();
}
  Future<String?> getValidAccessToken() async {
  final token = accessToken;
  if (token == null) return null;


  final newToken = await refreshAccessToken();
  return newToken ?? token;
}



  Future<void> setSession({
    required int id,
   
    required String accessToken,
    required String refreshToken,
  }) async {
    _id = id;
    
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await Future.wait([
      _storage.write(key: _kId, value: id.toString()),
   
      _storage.write(key: _kAccess, value: accessToken),
      _storage.write(key: _kRefresh, value: refreshToken),
    ]);

    notifyListeners();
  }

    Future<void> clearSession() async {
      _id = null;
     
      _accessToken = null;
      _refreshToken = null;
  _loggedOut = true;
  _isLoggedIn = false;
      await _storage.deleteAll();

      notifyListeners();
    }

  Future<String?> refreshAccessToken() async {
  if (_refreshFuture != null) {
    debugPrint("Refresh already in progress. Waiting...");
    return await _refreshFuture;
  }

  _refreshFuture = _performRefresh();

  try {
    return await _refreshFuture;
  } finally {
    _refreshFuture = null;
  }
}

Future<String?> _performRefresh() async {
  if (_refreshToken == null) {
    return null;
  }

  try {
    debugPrint("Refreshing access token...");

    final String baseUrl =
        dotenv.env['API_BASE_URL'] ?? '';

    final url = Uri.parse(
      "$baseUrl/client/token/refresh/",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refresh": _refreshToken,
      }),
    );

    debugPrint(
      "Refresh response: ${response.statusCode}",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _accessToken = data["access"];

      if (data["refresh"] != null) {
        _refreshToken = data["refresh"];

        await _storage.write(
          key: _kRefresh,
          value: _refreshToken,
        );
      }

      await _storage.write(
        key: _kAccess,
        value: _accessToken,
      );

      notifyListeners();

      debugPrint("Token refresh successful");

      return _accessToken;
    }

    debugPrint(
      "Refresh failed: ${response.body}",
    );

    await clearSession();

    return null;
  } catch (e) {
    debugPrint(
      "Refresh exception: $e",
    );

    await clearSession();

    return null;
  }
}
}