import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';

class SessionByShipmentController extends ChangeNotifier {
  bool isLoading = false;
  SessionModel? session; // single session
  String? errorMessage;

  Future<void> fetchSession(String shipmentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      session = await SessionApi.getSessionByShipment(shipmentId);
    } catch (e, stack) {
      errorMessage = e.toString();
      if (kDebugMode) {
        print("❌ ERROR in fetchSession: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) print("fetchSession() finished");
    }
  }
}
