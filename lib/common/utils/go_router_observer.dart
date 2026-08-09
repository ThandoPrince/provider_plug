import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:provider/provider.dart';

class ShipmentRefreshObserver extends NavigatorObserver {
  final BuildContext context;


  
  ShipmentRefreshObserver(this.context);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    // Check if we're returning to the Shipment screen
    if (previousRoute?.settings.name == '/scheduled_services') {
      // Refresh the ShipmentController
      final shipmentCtrl = Provider.of<ShipmentController>(context, listen: false);

debugPrint(
  "Observer ShipmentController: ${shipmentCtrl.hashCode}",
);
      shipmentCtrl.fetchShipments();
    }
  }
}
