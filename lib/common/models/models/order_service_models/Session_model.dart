import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class SessionModel {
  final int? sessionId;
  final int? shipmentId;
  final Shipment? shipment;
  final DateTime? checkinTime;
  final Map<String, dynamic>? checkinLocation;
  final DateTime? checkoutTime;
  final Map<String, dynamic>? checkoutLocation;
  final int? durationSeconds; 

  SessionModel({
    this.sessionId,
    this.shipmentId,
    this.shipment,
    this.checkinTime,
    this.checkinLocation,
    this.checkoutTime,
    this.checkoutLocation,
    this.durationSeconds,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'],
      shipmentId: json['shipment'] is int ? json['shipment'] : null,
      shipment: json['shipment'] is Map<String, dynamic>
          ? Shipment.fromJson(json['shipment'])
          : null,
      checkinTime: json['checkin_time'] != null
          ? DateTime.tryParse(json['checkin_time'])
          : null,
      checkinLocation: json['checkin_location'],
      checkoutTime: json['checkout_time'] != null
          ? DateTime.tryParse(json['checkout_time'])
          : null,
      checkoutLocation: json['checkout_location'],
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
      'duration_seconds': durationSeconds,
    };
  }
}
