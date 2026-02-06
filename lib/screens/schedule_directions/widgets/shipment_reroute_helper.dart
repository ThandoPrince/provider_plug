
import 'package:flutter_application_2/common/controller/bookings/get_shipment_route_controller.dart';

import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';

class ShipmentRouteHelper {
  final ShipmentRouteFetchController _controller = ShipmentRouteFetchController();

  /// Fetch latest route for a shipment
  Future<ShipmentRoute?> getLatestRoute(int shipmentId) async {
    await _controller.fetchShipmentRoutes(shipmentId);
    return _controller.latestRoute;
  }

  /// Optional: expose all routes
  List<ShipmentRoute> getAllRoutes() => _controller.routes;

  /// Clear cached data
  void clear() => _controller.clear();
}
