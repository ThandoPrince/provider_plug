

import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';

class AcceptNegotiationResponse {
  final bool success;
  final String message;
  final BookingItem? bookingItem;

  AcceptNegotiationResponse({
    required this.success,
    required this.message,
    this.bookingItem,
  });

  factory AcceptNegotiationResponse.fromJson(Map<String, dynamic> json) {
    return AcceptNegotiationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookingItem: json['booking_item'] != null
          ? BookingItem.fromJson(json['booking_item'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'booking_item': bookingItem?.toJson(),
      };
}

class BookingItem {
  final int? itemId;
  final int? orderId;
  final OrderService? order;
  final bool? checkedIn;
  final DateTime? checkinTime;
  final DateTime? checkOutTime;
  final Duration? duration;

  BookingItem({
    this.itemId,
    this.orderId,
    this.order,
    this.checkedIn,
    this.checkinTime,
    this.checkOutTime,
    this.duration,
  });

  factory BookingItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingItem();

    // Parse itemId safely
    int? parsedItemId;
    if (json['item_id'] != null) {
      parsedItemId = (json['item_id'] is int)
          ? json['item_id']
          : int.tryParse(json['item_id'].toString());
    }

    // Parse orderId safely
    int? parsedOrderId;
    if (json['order_id'] != null) {
      parsedOrderId = (json['order_id'] is int)
          ? json['order_id']
          : int.tryParse(json['order_id'].toString());
    }

    // Parse checkedIn safely
    bool? parsedCheckedIn;
    if (json['checked_in'] != null) {
      if (json['checked_in'] is bool) {
        parsedCheckedIn = json['checked_in'];
      } else {
        parsedCheckedIn = json['checked_in'].toString().toLowerCase() == 'true';
      }
    }

    // Parse dates safely
    DateTime? parsedCheckinTime;
    if (json['checkin_time'] != null) {
      parsedCheckinTime = DateTime.tryParse(json['checkin_time'].toString());
    }

    DateTime? parsedCheckOutTime;
    if (json['check_out_time'] != null) {
      parsedCheckOutTime = DateTime.tryParse(json['check_out_time'].toString());
    }

    // Parse duration safely
    Duration? parsedDuration;
    if (json['duration'] != null) {
      if (json['duration'] is int) {
        parsedDuration = Duration(seconds: json['duration']);
      } else if (json['duration'] is String) {
        final seconds = int.tryParse(json['duration']);
        if (seconds != null) parsedDuration = Duration(seconds: seconds);
      }
    }

    // Parse order safely
    OrderService? parsedOrder;
    if (json['order'] != null && json['order'] is Map<String, dynamic>) {
      parsedOrder = OrderService.fromJson(json['order']);
    }

    return BookingItem(
      itemId: parsedItemId,
      orderId: parsedOrderId,
      order: parsedOrder,
      checkedIn: parsedCheckedIn,
      checkinTime: parsedCheckinTime,
      checkOutTime: parsedCheckOutTime,
      duration: parsedDuration,
    );
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'order_id': orderId,
        'order': order?.toJson(),
        'checked_in': checkedIn,
        'checkin_time': checkinTime?.toIso8601String(),
        'check_out_time': checkOutTime?.toIso8601String(),
        'duration': duration?.inSeconds,
      };
}