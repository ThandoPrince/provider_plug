// lib/common/controller/bookings/provider_accept_negotiation_ctrl.dart
import 'package:flutter/foundation.dart';

import 'package:flutter_application_2/common/services/sp_accept_negotiation_api.dart';

class ProviderAcceptNegotiationCtrl extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get response => _response;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Accept the negotiation via API.
  /// Returns true on success, false on failure (see [error] for message).
  Future<bool> acceptNegotiation(int negotiationId) async {
    _setLoading(true);
    _error = null;
    _response = null;

    try {
      final Map<String, dynamic> result = await AcceptNegotiationApi.acceptNegotiationById(negotiationId);
      _response = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
