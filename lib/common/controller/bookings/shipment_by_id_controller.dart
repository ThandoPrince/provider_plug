import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/services/shipment_by_id_api.dart';

class ShipmentByIdController extends ChangeNotifier {
  final ShipmentByIdApi api = ShipmentByIdApi();

  bool isLoading = false;
  Shipment? shipment;
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

  Future<Shipment?> fetchShipmentById(int shipmentId) async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final result = await ShipmentByIdApi.fetchShipmentById(shipmentId);

      if (_disposed) return null;

      shipment = result;
      return result;
    } catch (e, stack) {
      if (_disposed) return null;

      errorMessage = e.toString();

      if (kDebugMode) {
        print("❌ ERROR in fetchShipmentById: $e");
        print("📌 STACKTRACE: $stack");
      }

      return null;
    } finally {
      if (_disposed) return null;

      isLoading = false;
      _safeNotify();
    }
  }

  void clearShipment() {
    shipment = null;
    errorMessage = null;
    _safeNotify();
  }
}