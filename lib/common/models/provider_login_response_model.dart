import 'dart:convert';

class ProviderLoginResponseModel {
  final bool? success;
  final String? message;
  final ProviderLoginData? data;

  // Preserving legacy fallback mappings for external files
  int? get id => data?.id;
  String? get email => data?.email;
  String? get accessToken => data?.accessToken;
  String? get refreshToken => data?.refreshToken;

  ProviderLoginResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory ProviderLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return ProviderLoginResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ProviderLoginData.fromJson(json['data']) : null,
    );
  }
}

class ProviderLoginData {
  final int id; // Extracted dynamically from JWT payload block
  final String email;
  final String isProfileCompleted;
  final String accessToken;
  final String refreshToken;

  ProviderLoginData({
    required this.id,
    required this.email,
    required this.isProfileCompleted,
    required this.accessToken,
    required this.refreshToken,
  });

  factory ProviderLoginData.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'] ?? '';
    int extractedId = 0;

    // Extracting the "sp_id" safely out of the middle segment of the JWT
    if (token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          // Normalize base64 URL string padding constraints
          String normalizedSource = base64Url.normalize(parts[1]);
          final String payloadString = utf8.decode(base64Url.decode(normalizedSource));
          final Map<String, dynamic> payload = jsonDecode(payloadString);
          extractedId = payload['sp_id'] ?? 0;
        }
      } catch (_) {
        // Fallback to safe default zero baseline on malformed token streams
        extractedId = 0;
      }
    }

    return ProviderLoginData(
      id: extractedId,
      email: json['email'] ?? '',
      isProfileCompleted: json['is_profile_completed'] ?? '',
      accessToken: token,
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}