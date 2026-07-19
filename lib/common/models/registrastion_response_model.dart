import 'dart:convert';

import 'package:flutter/foundation.dart';

class RegistrationResponseModel {
  final bool? success;
  final String? message;
  final ProviderLoginData? data;

  // Preserving legacy fallback mappings for external files
  int? get id => data?.id;
  String? get email => data?.email;
  String? get accessToken => data?.accessToken;
  String? get refreshToken => data?.refreshToken;

  RegistrationResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ProviderLoginData.fromJson(json['data']) : null,
    );
  }
}

class ProviderLoginData {
  final int id; // Extracted dynamically from JWT payload block
  final String email;
  final String is_profile_completed;
  final String accessToken;
  final String refreshToken;

  ProviderLoginData({
    required this.id,
    required this.email,
    required this.is_profile_completed,
    required this.accessToken,
    required this.refreshToken,
  });

  factory ProviderLoginData.fromJson(Map<String, dynamic> json) {
  if (kDebugMode) {
    print("========== ProviderLoginData ==========");
    print(json);
  }

  final token = json["access_token"] ?? "";

  int extractedId = json["id"] ?? 0;

  if (extractedId == 0 && token.isNotEmpty) {
    try {
      final parts = token.split(".");

      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(
            base64Url.decode(
              base64Url.normalize(parts[1]),
            ),
          ),
        );

        extractedId = payload["sp_id"] ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print("JWT Decode Error: $e");
      }
    }
  }

  return ProviderLoginData(
    id: extractedId,
    email: json["email"] ?? "",
    is_profile_completed:
        json["profile_status"] ??
        json["is_profile_completed"] ??
        "",
    accessToken: token,
    refreshToken: json["refresh_token"] ?? "",
  );
}
}