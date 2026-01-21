import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/services/get_provider_shipment_api.dart';

class ShipmentController extends ChangeNotifier {
  bool isLoading = false;
  List<Shipment> shipments = [];
  String? errorMessage;

  Future<void> fetchShipments(String providerEmail) async {
    

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
 

      shipments = await ShipmentApi.getShipmentsByProvider(providerEmail);

      
    } catch (e, stack) {
      errorMessage = e.toString();
      if (kDebugMode) {
        print("❌ ERROR in fetchShipments: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      isLoading = false;
      notifyListeners();

      if (kDebugMode) print("fetchShipments() finished");
    }
  }
}
