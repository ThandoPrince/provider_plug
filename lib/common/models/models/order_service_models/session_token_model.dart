import 'package:flutter_application_2/common/models/models/order_service_models/Session_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class SessionTokenModel {
  final int? tokenId;
  final String? checkinToken;
  final DateTime? tokenExpiry;
  final int? sessionId;
  final SessionModel? session;
  final int? shipmentId;
  final Shipment? shipment;
  final DateTime? createdAt;

  SessionTokenModel({
    this.tokenId,
    this.checkinToken,
    this.tokenExpiry,
    this.sessionId,
    this.session,
    this.shipmentId,
    this.shipment,
    this.createdAt,
  });

  factory SessionTokenModel.fromJson(Map<String, dynamic> json) {
    return SessionTokenModel(
      tokenId: json['token_id'],
      checkinToken: json['checkin_token'],
      tokenExpiry: json['token_expiry'] != null
          ? DateTime.tryParse(json['token_expiry'])
          : null,
      sessionId: json['session'] is int ? json['session'] : null,
      session: json['session'] is Map<String, dynamic>
          ? SessionModel.fromJson(json['session'])
          : null,
      shipmentId: json['shipment'] is int ? json['shipment'] : null,
      shipment: json['shipment'] is Map<String, dynamic>
          ? Shipment.fromJson(json['shipment'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_id': tokenId,
      'checkin_token': checkinToken,
      'token_expiry': tokenExpiry?.toIso8601String(),
      'session': session?.toJson() ?? sessionId,
      'shipment': shipment?.toJson() ?? shipmentId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isValid {
    if (tokenExpiry == null) return false;
    return DateTime.now().isBefore(tokenExpiry!);
  }
}
