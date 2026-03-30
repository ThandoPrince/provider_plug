import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class SessionModel {
  final int? sessionId;
  final int? shipmentId;
  final Shipment? shipment;

  final DateTime? checkinTime;
  final Map<String, dynamic>? checkinLocation;

  final DateTime? checkoutTime;
  final Map<String, dynamic>? checkoutLocation;

  final String? sessionStatus;
  final DateTime? dateCreated;

  final int? durationSeconds;

  SessionModel({
    this.sessionId,
    this.shipmentId,
    this.shipment,
    this.checkinTime,
    this.checkinLocation,
    this.checkoutTime,
    this.checkoutLocation,
    this.sessionStatus,
    this.dateCreated,
    this.durationSeconds,
  });

  factory SessionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SessionModel();

    return SessionModel(
      sessionId: json['session_id'] as int?,
      shipmentId: json['shipment'] is int ? json['shipment'] as int : null,
      shipment: json['shipment'] is Map<String, dynamic>
          ? Shipment.fromJson(json['shipment'] as Map<String, dynamic>)
          : null,
      checkinTime: json['checkin_time'] != null
          ? DateTime.tryParse(json['checkin_time'].toString())
          : null,
      checkinLocation: json['checkin_location'] is Map<String, dynamic>
          ? json['checkin_location'] as Map<String, dynamic>
          : null,
      checkoutTime: json['checkout_time'] != null
          ? DateTime.tryParse(json['checkout_time'].toString())
          : null,
      checkoutLocation: json['checkout_location'] is Map<String, dynamic>
          ? json['checkout_location'] as Map<String, dynamic>
          : null,
      sessionStatus: json['session_status']?.toString(),
      dateCreated: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'].toString())
          : null,
      durationSeconds: json['duration_seconds'] != null
          ? (json['duration_seconds'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'shipment': shipment?.toJson() ?? shipmentId,
      'checkin_time': checkinTime?.toIso8601String(),
      'checkin_location': checkinLocation,
      'checkout_time': checkoutTime?.toIso8601String(),
      'checkout_location': checkoutLocation,
      'session_status': sessionStatus,
      'date_created': dateCreated?.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
  }
}