import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/services/booking_by_orderID_api.dart';


class BookingByOrderIDController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  OrderService? booking;

  Future<void> fetchBookingByOrderID(int orderId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      booking = await BookingByOrderidApi.fetchBookingByOrderID(orderId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
