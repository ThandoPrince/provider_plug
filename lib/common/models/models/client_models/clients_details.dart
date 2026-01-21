import 'package:flutter_application_2/common/models/models/client_models/client_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientModel {
  static final String mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

  final ClientAuthModel? clientProfile;
  final String? firstName;
  final String? lastName;
  final String? rating;
  final String? clientPP;

  ClientModel({
    this.clientProfile,
    this.firstName,
    this.lastName,
    this.rating,
    this.clientPP,
  });

  factory ClientModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientModel();
    }

    return ClientModel(
      clientProfile: json['client_profile'] != null
          ? ClientAuthModel.fromJson(json['client_profile'] as Map<String, dynamic>?)
          : null,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      rating: json['rating'] as String?,
      clientPP: json['client_pp'] as String? ??
          json['profile_picture'] as String? ??
          json['pp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (clientProfile != null) 'client_profile': clientProfile?.toJson(),
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (rating != null) 'rating': rating,
      if (clientPP != null) 'client_pp': clientPP,
    };
  }

  // ✅ Helper: full name
  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  // ✅ Helper: profile picture URL (if needed)
  String? get profileImageUrl {
    if (clientPP == null) return null;
    if (clientPP!.startsWith("http")) return clientPP;

    // Remove leading slash if present
    final path = clientPP!.startsWith('/') ? clientPP!.substring(1) : clientPP!;
    return "$mediaBaseUrl/$path";
  }
}
