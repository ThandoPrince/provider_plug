import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_2/common/services/shipment_route_api.dart';

class ShipmentRouteController extends ChangeNotifier {
  bool isLoading = false;
  ShipmentRoute? shipmentRoute;
  String? errorMessage;

  /// Post or update a shipment route
  Future<void> saveShipmentRoute(ShipmentRoute route) async {
    if (kDebugMode) {
      print("🚀 saveShipmentRoute() called for shipmentId: ${route.shipmentId}");
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final savedRoute = await ShipmentRouteApi.postShipmentRoute(route);
      shipmentRoute = savedRoute;

      if (kDebugMode) {
        print("✅ ShipmentRoute saved: routeId=${savedRoute.routeId}");
      }
    } catch (e, stack) {
      errorMessage = e.toString();

      if (kDebugMode) {
        print("❌ ERROR in saveShipmentRoute: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      isLoading = false;
      notifyListeners();

      if (kDebugMode) print("🏁 saveShipmentRoute() finished");
    }
  }
}
