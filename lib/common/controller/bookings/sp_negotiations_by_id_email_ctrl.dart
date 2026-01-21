import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';
import 'package:flutter_application_2/common/services/get_sp_negotiation_api.dart';

class SpNegotiationsByIdEmailCtrl extends ChangeNotifier {
  final Map<String, List<NegotiationModel>> _negotiationsMap = {};
  final Map<String, bool> _loadingMap = {};
  final Map<String, String?> _errorMap = {};

  List<NegotiationModel> negotiations(String key) => _negotiationsMap[key] ?? [];
  bool isLoading(String key) => _loadingMap[key] ?? false;
  String? error(String key) => _errorMap[key];

  String _key(int orderId, String email) => '$orderId|${email.trim().toLowerCase()}';

  Future<void> loadNegotiations({required int orderId, required String email}) async {
    final key = _key(orderId, email);

    if (isLoading(key)) return;

    _loadingMap[key] = true;
    _errorMap[key] = null;
    notifyListeners();

    try {
      final fetchedNegotiations = await GetSpNegotiationApi.fetchNegotiations(
        orderId: orderId,
        email: email,
      );
      _negotiationsMap[key] = fetchedNegotiations;
      if (fetchedNegotiations.isEmpty) {
        _errorMap[key] = 'No negotiations found';
      }
    } catch (e) {
      _errorMap[key] = e.toString();
      _negotiationsMap[key] = [];
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> refreshNegotiations({required int orderId, required String email}) async {
    _negotiationsMap.remove(_key(orderId, email));
    await loadNegotiations(orderId: orderId, email: email);
  }

  void clearAll() {
    _negotiationsMap.clear();
    _loadingMap.clear();
    _errorMap.clear();
    notifyListeners();
  }
}
