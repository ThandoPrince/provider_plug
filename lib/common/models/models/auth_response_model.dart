import 'package:flutter_application_2/common/models/provider_login_response_model.dart';

class ProviderAuthResponse {
  final bool success;
  final String? message;
  final ProviderLoginResponseModel? data;

  ProviderAuthResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ProviderAuthResponse.fromJson(Map<String, dynamic> json) {
    return ProviderAuthResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? ProviderLoginResponseModel.fromJson(json['data'])
          : null,
    );
  }
}