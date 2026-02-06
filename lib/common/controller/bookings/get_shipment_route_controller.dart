import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_2/common/services/shipment_route_api.dart';

class ShipmentRouteFetchController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<ShipmentRoute> routes = [];
  ShipmentRoute? latestRoute;

  /// Fetch routes for a shipment
  Future<void> fetchShipmentRoutes(int shipmentId) async {
    if (kDebugMode) {
      print("📡 Fetching routes for shipmentId=$shipmentId");
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      routes = await ShipmentRouteApi.getShipmentRoutes(shipmentId);

      if (routes.isNotEmpty) {
        // Backend already orders by -created_at
        latestRoute = routes.first;

        if (kDebugMode) {
          print("✅ Latest route loaded: routeId=${latestRoute!.routeId}");
        }
      } else {
        latestRoute = null;

        if (kDebugMode) {
          print("ℹ️ No routes found for shipment $shipmentId");
        }
      }
    } catch (e, stack) {
      errorMessage = e.toString();

      if (kDebugMode) {
        print("❌ Failed to fetch shipment routes: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    routes.clear();
    latestRoute = null;
    errorMessage = null;
    notifyListeners();
  }
}
