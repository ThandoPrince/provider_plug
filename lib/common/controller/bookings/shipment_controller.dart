import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/services/get_provider_shipment_api.dart';

class ShipmentController extends ChangeNotifier {

  String _selectedFilter = "All";

  String get selectedFilter => _selectedFilter;

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
  bool isLoading = false;
  List<Shipment> shipments = [];
  String? errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Fetch shipments and merge diff (update existing, add new)
  Future<void> fetchShipments() async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final data = await ShipmentApi.getShipmentsByProvider();

      if (_disposed) return;

      // --- DIFF UPDATE ---
      final Map<int, Shipment> currentMap = {
        for (var s in shipments) s.shipmentId!: s
      };
      final List<Shipment> mergedList = [];

      for (var newShipment in data) {
        if (currentMap.containsKey(newShipment.shipmentId)) {
          // Replace with new version
          mergedList.add(newShipment);
          currentMap.remove(newShipment.shipmentId);
        } else {
          // Add new shipment
          mergedList.add(newShipment);
        }
      }


      shipments = mergedList;
    } catch (e, stack) {
      if (_disposed) return;
      errorMessage = e.toString();
      if (kDebugMode) {
        print("❌ ERROR in fetchShipments: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      if (_disposed) return;
      isLoading = false;
      _safeNotify();

      if (kDebugMode) print("fetchShipments() finished (diff applied)");
    }
  }


  void clearShipments() {
    shipments.clear();
    errorMessage = null;
    _safeNotify();
  }
}
