import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/services/new_bookings_by_email_api.dart';


class SPBookingController with ChangeNotifier {
  List<OrderService> _activeBookings = [];
  String? _errorMessage;

  List<OrderService> get activeBookings => _activeBookings;
  String? get errorMessage => _errorMessage;

  Timer? _timer;

  // Start polling every 10 seconds (optional backup)
  Future<void> startPolling(String email) async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await fetchActiveBookings(email, append: false);
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // Fetch bookings, optionally append to current list
  Future<void> fetchActiveBookings(String email, {bool append = true}) async {
    try {
      final newBookings = await NewBookingsByEmailApi.fetchNewBookingByEmail(email);

      if (append) {
        // Only add bookings that are not already in the list
        for (var b in newBookings) {
          if (!_activeBookings.any((existing) => existing.orderId == b.orderId)) {
            _activeBookings.add(b);
          }
        }
      } else {
        // Replace full list (used for full refresh)
        _activeBookings = newBookings;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Call this when a new booking is submitted
  void addBooking(OrderService booking) {
    if (!_activeBookings.any((b) => b.orderId == booking.orderId)) {
      _activeBookings.insert(0, booking); // insert at top
      notifyListeners();
    }
  }
}
