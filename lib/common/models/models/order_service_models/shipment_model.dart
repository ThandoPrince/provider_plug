import 'package:flutter_application_2/common/models/models/order_service_models/booking_item_model.dart';

class Shipment {
  final int? shipmentId;
  final DateTime? shipmentScheduleDate;
  final String? shipmentScheduleTime;
  final String? shipmentStatus;
  final bool? shipmentConfirmation;
  final BookingItem? serviceOrdered;
  final DateTime? createdAt;

  Shipment({
    this.shipmentId,
    this.shipmentScheduleDate,
    this.shipmentScheduleTime,
    this.shipmentStatus,
    this.shipmentConfirmation,
    this.serviceOrdered,
    this.createdAt,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    // Parse shipmentId safely
    int? parsedShipmentId;
    if (json['shipment_id'] != null) {
      parsedShipmentId = (json['shipment_id'] is int)
          ? json['shipment_id']
          : int.tryParse(json['shipment_id'].toString());
    }

    // Parse shipment schedule date safely
    DateTime? parsedScheduleDate;
    if (json['shipment_schedule_date'] != null) {
      parsedScheduleDate = DateTime.tryParse(json['shipment_schedule_date'].toString());
    }

    // Parse shipment confirmation safely
    bool? parsedConfirmation;
    if (json['shipment_confirmation'] != null) {
      if (json['shipment_confirmation'] is bool) {
        parsedConfirmation = json['shipment_confirmation'];
      } else {
        parsedConfirmation = json['shipment_confirmation'].toString().toLowerCase() == 'true';
      }
    }

    // Parse createdAt safely
    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    // Parse serviceOrdered safely
    BookingItem? parsedServiceOrdered;
    if (json['service_ordered'] != null && json['service_ordered'] is Map<String, dynamic>) {
      parsedServiceOrdered = BookingItem.fromJson(json['service_ordered']);
    }

    return Shipment(
      shipmentId: parsedShipmentId,
      shipmentScheduleDate: parsedScheduleDate,
      shipmentScheduleTime: json['shipment_schedule_time']?.toString(),
      shipmentStatus: json['shipment_status']?.toString(),
      shipmentConfirmation: parsedConfirmation,
      serviceOrdered: parsedServiceOrdered,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'shipment_id': shipmentId,
        'shipment_schedule_date': shipmentScheduleDate?.toIso8601String().split('T')[0],
        'shipment_schedule_time': shipmentScheduleTime,
        'shipment_status': shipmentStatus,
        'shipment_confirmation': shipmentConfirmation,
        'service_ordered': serviceOrdered?.toJson(),
        'created_at': createdAt?.toIso8601String(),
      };
}

