import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/services/start_sp_provider_negotiation_api.dart';

class SpNegotiationRoundCtrl with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  NegotiationRound? _latestRound;
  bool _inNegotiation = false; // 

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NegotiationRound? get latestRound => _latestRound;
  bool get inNegotiation => _inNegotiation;

  
  Future<void> startRound({
    required int negotiationId,
    required String providerEmail,
    String? message,
    double? offeredPrice,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final round = await StartSpProviderNegotiationApi.startProviderRound(
        negotiationId: negotiationId,
        providerEmail: providerEmail,
        message: message,
        offeredPrice: offeredPrice,
      );

      if (round != null) {
        _latestRound = round;
        _inNegotiation = true; 
      } else {
        _errorMessage = "Failed to start negotiation round.";
      }
    } catch (e) {
      _errorMessage = "Error: ${e.toString()}";
      if (kDebugMode) {
        print("❌ [SpNegotiationRoundCtrl] startRound() failed: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the negotiation controller (optional for UI cleanup)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _latestRound = null;
    _inNegotiation = false;
    notifyListeners();
  }
}
