
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const Duration timeout = Duration(seconds: 30);

  void Function()? onSessionExpired;

  void setSessionExpiredHandler(void Function() handler) {
    onSessionExpired = handler;
  }

  String? get accessToken =>
      AuthSessionController.instance.accessToken;  String? getAccessToken() {
  return AuthSessionController.instance.accessToken;
}

    Future<http.Response> multipartRequest(
    Future<http.MultipartRequest> Function(String? token) builder,
  ) async {
    try {
      String? token = accessToken;

      http.MultipartRequest request =
          await builder(token);

      http.StreamedResponse streamed =
          await request.send().timeout(timeout);

      http.Response response =
          await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        response = await _retryMultipart(builder);
      }

      return response;
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    }
  }


    Future<http.Response> request(
    Future<http.Response> Function(String? token) builder,
  ) async {
    try {
      String? token = accessToken;

      http.Response response =
          await builder(token).timeout(timeout);

      if (response.statusCode == 401) {
        response = await _retry(builder);
      }

      return response;
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    }
  }

  Future<http.Response> _retry(
    Future<http.Response> Function(String? token) builder,
) async {

    final token =
        await AuthSessionController.instance.refreshAccessToken();

    if (token == null) {
      await AuthSessionController.instance.clearSession();

      onSessionExpired?.call();

      throw const SessionExpiredException();
    }

    return builder(token);
}

Future<http.Response> _retryMultipart(
    Future<http.MultipartRequest> Function(String? token) builder,
) async {

    final token =
        await AuthSessionController.instance.refreshAccessToken();

    if (token == null) {
      await AuthSessionController.instance.clearSession();

      onSessionExpired?.call();

      throw const SessionExpiredException();
    }

    final request = await builder(token);

    request.headers["Authorization"] =
        "Bearer $token";

    final streamed =
        await request.send().timeout(timeout);

    return http.Response.fromStream(streamed);
}
}